fs = require 'fs'
url = require 'url'
path = require 'path'
https = require 'https'
mime = require 'mime'
Server = require 'lib/https-server'

task 'resource-server:start', 'start local https server to serve
  local resources', (options) ->

  srv = new Server()
  srv.createServer (err, server) ->
    throw err if err

    server.on 'request', (req, res) ->
      uri = url.parse(request.url).pathname
      filename = path.join(process.cwd(), uri)

      # avoid transversal directory attacks
      if filename.indexOf(process.cwd()) is not 0
        # TODO create a function for 404
        res.writeHead 404, 'content-type': 'text/plain'
        res.write '404 Not Found\n'
        res.end()
        return

      path.exists filename, (exists) ->
        if !exists
          # TODO create a function for 404
          res.writeHead 404, 'content-type': 'text/plain'
          res.write '404 Not Found\n'
          res.end()
          return

        # if dir server the default index.html file (js?)
        if fs.statSync(filename).isDirectory()
          filename = path.normalize("#{filename}/index.html")

        fs.readFile filename, 'binary', (err, file) ->
          if err
            res.writeHead 500, 'content-type': 'text/plain'
            res.write "#{err}\n"
            res.end()
            return

          res.writeHead 200, 'content-type': mime.lookup(filename)
          res.write file, 'binary'
          res.end()

    #request { port: server.port, ca: [server.cert] }, (err, data) ->
    #  server.close()
    #  throw err if err
    #  console.log 'success:', data.toString() is raw
    #  return

    return

  request = (options, callback) ->
    options.hostname = 'localhost'
    options.path = '/'

    req = https.get(options, (res) ->

      res.on 'error', callback

      data = []
      length = 0
      res.on 'data', (chunk) ->
        data.push chunk
        length += chunk.length
        return

      res.on 'end', ->
        callback null, Buffer.concat(data, length)
        return

      return
    )
    req.on 'error', callback
    return
