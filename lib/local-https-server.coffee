{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
keypair = require 'self-signed'
fs = require 'fs'
path = require 'path'
file = require 'file'

module.exports =
class LocalHttpsServer
  _Hapi = null
  _key = null
  _cert = null

  constructor: ->
    _key = path.normalize("#{__dirname}/../cert/server.key")
    _cert = path.normalize("#{__dirname}/../cert/server.cert")
    allowUnsafeNewFunction ->
      _Hapi ?= require 'hapi'

  _generateTlsOptions = ->
    options = keypair(
      name: "localhost"
      city: "Nashville01"
      state: "Tennessee"
      organization: "atom-sfdc-ba"
      unit: "atom-sfdc-ba"
    ,
      alt: ["127.0.0.1"])

    tlsOptions =
      key: options.private
      cert: options.cert

    # "cache" that shit
    _writeCertToFs(tlsOptions)

    tlsOptions

  _writeCertToFs = (options) ->
    file.mkdirsSync path.dirname(_key)
    file.mkdirsSync path.dirname(_cert)

    fs.writeFile _key, options.private, (err, res) ->
    fs.writeFile _cert, options.cert, (err, res) ->

  start: ->
    tlsOptions = null

    # use certs that already exists
    if fs.existsSync(_key) and fs.existsSync(_cert)
      tlsOptions =
        key: fs.readFileSync(_key)
        cert: fs.readFileSync(_cert)
    else
      tlsOptions = _generateTlsOptions()

    files =
      relativeTo: __dirname

    _server = new _Hapi.Server('localhost', 8080,
      { tls: tlsOptions, files: files })

    _server.route
      method: 'GET'
      path: '/resources/{path*}'
      handler:
        directory:
          path: './resources'

    _server.on 'close', (err, res) ->
      console.debug 'close'

    _server.start ->
      console.log('Server running at:', _server.info.uri)

    _server.inject '/resources/index.html', (res) ->
      console.debug 'status: %s', res.statusCode
