AtomSfdcBaView = require './atom-sfdc-ba-view'

module.exports =
  atomSfdcBaView: null
  configDefaults:
    loginUrl: 'https://login.salesforce.com'
    username: null
    password: null
    securityToken: null
    apiVersion: 'xx.x'
    resourceDirectory: 'resource-bundles'
    sfdcInstance: 'na11'

  activate: (state) ->
    @atomSfdcBaView = new AtomSfdcBaView(state.atomSfdcBaViewState)

  deactivate: ->
    @atomSfdcBaView.destroy()

  serialize: ->
    atomSfdcBaViewState: @atomSfdcBaView.serialize()
