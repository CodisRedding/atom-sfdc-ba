{View} = require 'atom'
LocalHttpsServer = require './local-https-server'

PageLocaliser = null

module.exports =
class AtomSfdcBaView extends View
  _server = null

  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    resDir = atom.config.get("atom-sfdc-ba.resourceDirectory")
    _server = new LocalHttpsServer(atom.project.path, resDir)
    atom.workspaceView.command "atom-sfdc-ba:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AtomSfdcBaView was toggled!"
    if @hasParent()
      #_server?.stop()
      @detach()
    else
      _server.start().done (srv) ->
        PageLocaliser ?= require './page-localiser'
        PageLocaliser.launchit "https://staging-gbhem.cs10.force.com/pastoralacts?port=#{srv.info.port}"

      atom.workspaceView.append(this)
