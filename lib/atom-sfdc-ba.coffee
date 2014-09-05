AtomSfdcBaView = require './atom-sfdc-ba-view'

module.exports =
  atomSfdcBaView: null

  activate: (state) ->
    @atomSfdcBaView = new AtomSfdcBaView(state.atomSfdcBaViewState)

  deactivate: ->
    @atomSfdcBaView.destroy()

  serialize: ->
    atomSfdcBaViewState: @atomSfdcBaView.serialize()
