{View} = require 'atom'

module.exports =
class AtomSfdcBaView extends View
  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
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
      atom.workspaceView.append(this)
