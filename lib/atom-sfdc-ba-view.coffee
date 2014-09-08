{View} = require 'atom'
LocalHttpsServer = require './local-https-server'

module.exports =
class AtomSfdcBaView extends View
  _server = null

  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    _server = new LocalHttpsServer()
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
      _server.start()
      atom.workspaceView.append(this)
