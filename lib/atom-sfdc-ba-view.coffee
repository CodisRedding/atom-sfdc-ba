{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
{View} = require 'atom'
keypair = require 'self-signed'

module.exports =
class AtomSfdcBaView extends View
  _Hapi = null
  _server = null

  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    allowUnsafeNewFunction ->
      _Hapi ?= require 'hapi'
    atom.workspaceView.command "atom-sfdc-ba:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AtomSfdcBaView was toggled!"
    if @hasParent()
      @detach()
    else
      # generate self-signed cert
      options = keypair
        name: "localhost"
        city: "Nashville"
        state: "Tennessee"
        organization: "atom-sfdc-ba"
        unit: "atom-sfdc-ba"
      ,
        alt: ["127.0.0.1"]

      # setup tls options for server
      tlsOptions =
        key: options.private
        cert: options.cert

      _server = new _Hapi.Server('localhost', '8080', tls: tlsOptions)
      _server.route
        method: 'GET'
        path: '/{param*}'
        handler:
          directory:
            path: 'resources'

      atom.workspaceView.append(this)
