{View} = require 'atom'
LocalHttpsServer = require './local-https-server'
Salesforce = require './salesforce'

PageLocaliser = null

module.exports =
class AtomSfdcBaView extends View
  _server = null
  _resDir = null
  _apiVersion = null
  _pod = null
  _sid = null
  _salesforce = null

  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    _salesforce = new Salesforce()
    _resDir = atom.config.get("atom-sfdc-ba.resourceDirectory")
    _apiVersion = atom.config.get("atom-sfdc-ba.apiVersion")
    _pod = atom.config.get("atom-sfdc-ba.sfdcInstance")
    _server = new LocalHttpsServer(atom.project.path, _resDir)
    atom.workspaceView.command "atom-sfdc-ba:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AtomSfdcBaView was toggled!"
    if @hasParent()
      _server?.stop()
      @detach()
    else
      _server.start().done (srv) ->
        _salesforce.login (err, res) ->
          return console.error err if err

          PageLocaliser ?= require './page-localiser'
          settings =
            "port": srv.info.port
            "resourceDir": _resDir
            "api": _apiVersion
            "pod": _pod
            "sid": _salesforce.getSessionId()

          param = escape(JSON.stringify(settings))
          PageLocaliser.launchit "https://staging-gbhem.cs10.force.com/pastoralacts?p=#{param}"
          # PageLocaliser.launchit "https://staging-gbhem.cs10.force.com/pastoralacts?port=#{srv.info.port}&rd=#{escape(_resDir)}&api=#{escape(_apiVersion)}&pod=#{escape(_pod)}&sid=#{escape(_sid)}"

      atom.workspaceView.append(this)
