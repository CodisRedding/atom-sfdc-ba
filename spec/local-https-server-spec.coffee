LocalHttpsServer = require '../lib/local-https-server'
fs = require 'fs'
path = require 'path'
temp = require 'temp'
Promise = require 'bluebird'
request = Promise.promisify(require 'request')

describe 'LocalHttpsServer', ->
  [server, resourceDir] = []

  beforeEach ->
    resourceDir = 'resource-bundles'
    directory = temp.mkdirSync()
    atom.project.setPath(directory)
    resDir = path.join(directory, resourceDir)
    fs.mkdirSync resDir
    fs.writeFileSync path.join(resDir, 'index.html'), 'twerking'
    server = new LocalHttpsServer(atom.project.path, resourceDir)

  afterEach ->
    server.stop()
    server = null

  it 'returns a file when requesting a file from within a directory', ->
    responded = false
    response = null

    server.start().done ->
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

      request("https://localhost:8000/#{resourceDir}/index.html").then (res) ->
        response = res[0]
        responded = true

    waitsFor ->
      return responded

    runs ->
      expect(response.statusCode).toBe(200)
      expect(response.body).toContain('twerking')

  it 'returns default file when requesting directory', ->
    responded = false
    response = null

    server.start().done ->
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

      request("https://localhost:8000/#{resourceDir}").then (res) ->
        response = res[0]
        responded = true

    waitsFor ->
      return responded

    runs ->
      expect(response.statusCode).toBe(200)
      expect(response.body).toContain('twerking')

  it 'should not serve files after stop is called', ->
    responded = false
    response = null

    server.start().done ->
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

      server.stop()
      request("https://localhost:8000/#{resourceDir}/index.html").then((res) ->
        # shouldn't happen
      )
      .catch (error) ->
        response = error.message
        responded = true


    waitsFor ->
      return responded

    runs ->
      expect(response).toContain('ECONNREFUSED')
