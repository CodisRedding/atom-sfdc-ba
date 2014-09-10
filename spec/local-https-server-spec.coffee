LocalHttpsServer = require '../lib/local-https-server'
fs = require 'fs'
path = require 'path'
temp = require 'temp'
Promise = require 'bluebird'
request = Promise.promisify(require 'request')

describe 'LocalHttpsServer', ->
  [server, resourceDir, responded, response, uri] = []

  beforeEach ->
    resourceDir = 'resource-bundles'
    directory = temp.mkdirSync()
    atom.project.setPath(directory)
    resDir = path.join(directory, resourceDir)
    fs.mkdirSync resDir
    fs.writeFileSync path.join(resDir, 'index.html'), 'twerking'
    server = new LocalHttpsServer(atom.project.path, resourceDir)
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"
    uri = []

  afterEach ->
    server.stop()
    server = null

  it 'should have a uri of https://localhost', ->
    server.start().done (srv) ->
      uri = srv.info.uri
      responded = true

    waitsFor ->
      return responded

    runs ->
      expect(uri).toContain('https://localhost')

  fit 'multiple servers should have unique ports', ->
    [port1, port2] = []
    server.start().then (srv) ->
      port1 = srv.info.port
      server2 = new LocalHttpsServer(atom.project.path, resourceDir)
      server2.start().then (srv2) ->
        port2 = srv2.info.port
        server2.stop()
        responded = true

    waitsFor ->
      return responded

    runs ->
      expect(port1).not.toBe(port2)


  it 'returns a file when requesting a file from within a directory', ->
    server.start().done (srv) ->
      uri = srv.info.uri
      request("#{uri}/#{resourceDir}/index.html").then (res) ->
        response = res[0]
        responded = true

    waitsFor ->
      return responded

    runs ->
      expect(response.statusCode).toBe(200)
      expect(response.body).toContain('twerking')

  it 'returns default file when requesting directory', ->
    server.start().done (srv) ->
      uri = srv.info.uri
      request("#{uri}/#{resourceDir}").then (res) ->
        response = res[0]
        responded = true

    waitsFor ->
      return responded

    runs ->
      expect(response.statusCode).toBe(200)
      expect(response.body).toContain('twerking')

  it 'should not serve files after stop is called', ->
    server.start().done (srv) ->
      server.stop()
      uri = srv.info.uri
      request("#{uri}/#{resourceDir}/index.html").then((res) ->
        # shouldn't happen
      )
      .catch (error) ->
        response = error.message
        responded = true


    waitsFor ->
      return responded

    runs ->
      expect(response).toContain('ECONNREFUSED')
