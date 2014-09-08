{SelectListView} = require 'atom'
module.exports =
class AtomSfdcBaMenuChoicesView extends SelectListView
  initialize: (menuChoices)->
    super
    @addClass('overlay from-top')
    # @setItems(['Hello', 'World'])
    path = require 'path'
    menuChoiceInfoArr = []
    for menuChoice in menuChoices
      menuChoiceInfo =
        filename: menuChoice
        label: path.basename(menuChoice)
      menuChoiceInfoArr.push(menuChoiceInfo)
    @setItems(menuChoiceInfoArr)
    atom.workspaceView.append(this)
    @focusFilterEditor()

  viewForItem: (item) ->
    "<li class='atom-sfdc-ba-menu-choice' data-item-url='#{item.filename}'>#{item.label}</li>"

  confirmed: (item) ->
    #now unzip the stupid thing
    AdmZip = require "adm-zip"
    zip = new AdmZip(item.filename);
    projectRoot = atom.project.rootDirectory.path
    zip.extractAllTo(projectRoot+'/resources/'+item.label,true);
    @cancel()
