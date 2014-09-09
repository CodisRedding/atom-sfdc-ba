{WorkspaceView} = require 'atom'
AtomSfdcBa = require '../lib/atom-sfdc-ba'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomSfdcBa", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    activationPromise = atom.packages.activatePackage('atom-sfdc-ba')

  describe "when the atom-sfdc-ba:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.atom-sfdc-ba')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'atom-sfdc-ba:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.atom-sfdc-ba')).toExist()
        atom.workspaceView.trigger 'atom-sfdc-ba:toggle'
        expect(atom.workspaceView.find('.atom-sfdc-ba')).not.toExist()
