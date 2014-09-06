keypair = require 'self-signed'
https = require 'https'
portfinder = require 'portfinder'
url = require 'url'
path = require 'path'
fs = require 'fs'

class HttpsServer

  start: ->
    _createServer (err, server) ->
      return console.error err if err

      server.on 'request', (req, res) ->
        uri = url.parse(req.url).pathname
        filename = path.join(process.cwd(), uri)

        console.log filename

        # avoid transversal directory attacks
        if filename.indexOf(process.cwd()) != 0
          # TODO create function for 404
          res.writeHead 404, "Content-Type": "text/plain"
          res.write "404 Not Found\n"
          res.end()
          return

        fs.exists filename, (exists) ->
          if !exists
            # TODO create function for 404
            res.writeHead 404, "Content-Type": "text/plain"
            res.write "404 Not Found\n"
            res.end()
            return

          # if req is a dir serve the index file of that dir
          if fs.statSync(filename).isDirectory()
            filename = path.normalize("filename/#{index.html}")

          fs.readFile filename, "binary", (err, file) ->
            if err
              res.writeHead 500, "Content-Type": "text/plain"
              res.write "#{err}\n"
              res.end()
              return

            res.writeHead 200, "Content-Type": mime.lookup(filename)
            res.write file, "binary"
            res.end()

        return

  _createServer = (callback) ->
    options = keypair(
      name: "localhost"
      city: "Nashville6"
      state: "Tennessee"
      organization: "Test"
      unit: "Test"
    ,
      alt: ["127.0.0.1"]
    )

    # server automatically sets up a .cert property
    server = https.createServer(
      key: options.private
      cert: options.cert
    )

    portfinder.getPort (err, port) ->
      return callback(err)  if err
      server.port = port
      server.listen port, "localhost", ->
        console.debug 'port %s', port
        callback null, server
        return

      return

    server

module.exports = HttpsServer
