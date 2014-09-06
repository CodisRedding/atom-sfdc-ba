{View} = require 'atom'
HttpServer = require './https-server'

module.exports =
class AtomSfdcBaView extends View
  _https = null

  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    _https = new HttpServer()
    atom.workspaceView.command "atom-sfdc-ba:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AtomSfdcBaView was toggled!"

    if @hasParent()
      #  close server
      @detach()
    else
      _https.start()
      atom.workspaceView.append(this)
