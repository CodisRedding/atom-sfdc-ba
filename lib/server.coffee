{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
keypair = require 'self-signed'
_Hapi = null
fs = require 'fs'
path = require 'path'

allowUnsafeNewFunction ->
  _Hapi ?= require 'hapi'

# setup tls options for server
tlsOptions = null
key = path.join(__dirname, 'server.key')
cert = path.join(__dirname, 'server.cert')

# use certs that already exists
if fs.existsSync(key) and fs.existsSync(cert)
  tlsOptions =
    key: fs.readFileSync(key)
    cert: fs.readFileSync(cert)
else
  # generate self-signed cert
  options = keypair(
    name: "localhost"
    city: "Nashville10"
    state: "Tennessee"
    organization: "atom-sfdc-ba"
    unit: "atom-sfdc-ba"
  ,
    alt: ["127.0.0.1"])

  tlsOptions =
    key: options.private
    cert: options.cert

  fs.writeFileSync(key, options.private)
  fs.writeFileSync(cert, options.cert)

files =
  relativeTo: __dirname

_server = new _Hapi.Server('localhost', 8080, { tls: tlsOptions, files: files })
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
