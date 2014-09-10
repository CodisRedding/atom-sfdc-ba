{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
keypair = require 'self-signed'
path = require 'path'
file = require 'file'
Promise = require 'bluebird'

fs = require 'fs'


module.exports =
class LocalHttpsServer
  _Hapi = undefined
  _cert = undefined
  _key = undefined
  _resourceDir = undefined
  _projectPath = undefined

  constructor: (projectPath, resourceDir) ->
    _server = undefined
    _projectPath = projectPath
    _resourceDir = resourceDir
    _key = path.normalize("#{__dirname}/../cert/server.key")
    _cert = path.normalize("#{__dirname}/../cert/server.cert")
    allowUnsafeNewFunction ->
      _Hapi ?= require 'hapi'
    Promise.promisifyAll(_Hapi.Server.prototype)

  # Public: returns private property _server
  #
  # Returns the _server as `undefined`.
  getServer: ->
    _server

  # Public: stops a running server
  #
  stop: ->
    _server?.stop()
    console.log 'Server stopped'

  # Public: Starts the server
  #
  # Returns the the underlying server engine as a promise.
  start: ->
    # create new server
    options = _configureServerOptions()
    _server = new _Hapi.Server('localhost', 0, options)

    # configure resource route
    _server.route
      method: 'GET'
      path: "/#{_resourceDir}/{path*}"
      handler:
        directory:
          path: "./#{_resourceDir}"

    # log when server ends
    _server.on 'close', (err, res) ->
      console.debug 'close'

    # start server
    _server.startAsync().then ->
      console.log '_server.info.port: ', _server.info.port
      console.log 'Server running at: ', _server.info.uri
      return _server

  # Private: Sets up tls configuration needed for https server
  #
  # Returns the configuration object for Hapi server.
  _configureServerOptions = ->
    tlsOptions = []

    # use certs that already exists
    if fs.existsSync(_key) and fs.existsSync(_cert)
      tlsOptions =
        key: fs.readFileSync(_key)
        cert: fs.readFileSync(_cert)
    else
      cert = _generateCert()
      _writeCertToFs(cert)
      tlsOptions =
        key: cert.private
        cert: cert.cert

    files =
      relativeTo: _projectPath

    { tls: tlsOptions, files: files }

  # Private: Generates a local self-signed cert in memory
  #
  # Returns the cert.
  _generateCert = ->
    cert = keypair
      name: "localhost"
      city: "Nashville01"
      state: "Tennessee"
      organization: "atom-sfdc-ba"
      unit: "atom-sfdc-ba"
    ,
      alt: ["127.0.0.1"]

    cert

  # Private: Writes a self-signed cert to the fs
  #
  # cert - The cert generated from _generateCert.
  #
  _writeCertToFs = (cert) ->
    file.mkdirsSync path.dirname(_key)
    file.mkdirsSync path.dirname(_cert)

    fs.writeFile _key, cert.private, (err, res) ->
    fs.writeFile _cert, cert.cert, (err, res) ->
