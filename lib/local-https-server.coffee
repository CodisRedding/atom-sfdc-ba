{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
keypair = require 'self-signed'
fs = require 'fs'
path = require 'path'
file = require 'file'
portFinder = require 'portfinder'

module.exports =
class LocalHttpsServer
  _Hapi = null
  _key = null
  _cert = null
  _resourceDir = null

  constructor: (resourceDir) ->
    console.debug 'resourceDir: %s', resourceDir
    _resourceDir = resourceDir
    _key = path.normalize("#{__dirname}/../cert/server.key")
    _cert = path.normalize("#{__dirname}/../cert/server.cert")
    allowUnsafeNewFunction ->
      _Hapi ?= require 'hapi'

  start: ->
    options = _configureServerOptions()
    portFinder.getPort (err, port) ->
      _server = new _Hapi.Server('localhost', port, options)

      _server.route
        method: 'GET'
        path: "/#{_resourceDir}/{path*}"
        handler:
          directory:
            path: "./#{_resourceDir}"

      _server.on 'close', (err, res) ->
        console.debug 'close'

      _server.start ->
        console.log('Server running at:', _server.info.uri)

      _server.inject '/resource-bundles/twerk.html', (res) ->
        console.debug 'status: %s', res.statusCode

  _configureServerOptions = ->
    tlsOptions = null

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
      relativeTo: atom.project.path

    { tls: tlsOptions, files: files }

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

  _writeCertToFs = (cert) ->
    file.mkdirsSync path.dirname(_key)
    file.mkdirsSync path.dirname(_cert)

    fs.writeFile _key, cert.private, (err, res) ->
    fs.writeFile _cert, cert.cert, (err, res) ->
