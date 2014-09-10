LocalHttpsServer = require '../lib/local-https-server'

temp = require 'temp'
Promise = require 'bluebird'
request = Promise.promisify(require 'request')

fs = require 'fs'
path = require 'path'


describe 'LocalHttpsServer', ->
  server = null
  resourceDir = null
  responded = false
  response = null
  uri = null

  beforeEach ->
    resourceDir = 'resource-bundles'
    directory = temp.mkdirSync()
    atom.project.setPath(directory)
    resDir = path.join(directory, resourceDir)
    fs.mkdirSync resDir
    fs.writeFileSync path.join(resDir, 'index.html'), 'twerking'
    server = new LocalHttpsServer(atom.project.path, resourceDir)
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"
    uri = false
    responded = null

  afterEach ->
    server?.stop()

  it 'multiple servers should have unique ports', ->

    port1 = undefined
    port2 = undefined
    server1Done = false
    server2Done = false

    server = new LocalHttpsServer(atom.project.path, resourceDir)
    server2 = new LocalHttpsServer(atom.project.path, resourceDir)

    server.start().done (srv) ->
      port1 = srv.info.port
      server1Done = true

    server2.start().done (srv) ->
      port2 = srv.info.port
      server2.stop()
      server2Done = true

    waitsFor ->
      return server1Done and server2Done

    runs ->
      expect(port1).not.toBe(undefined)
      expect(port2).not.toBe(undefined)
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
      srv.stop()
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
