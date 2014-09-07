{View} = require 'atom'

AtomSfdcBaMenuChoicesView = require './atom-sfdc-ba-menu-choices-view'

module.exports =
class AtomSfdcBaView extends View
  @content: ->
    @div class: 'atom-sfdc-ba overlay from-top', =>
      @div "The AtomSfdcBa package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "atom-sfdc-ba:toggle", => @toggle()
    atom.workspaceView.command "atom-sfdc-ba:resourceConvert", => @convertToResource()

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


  convertToResource: ->
    console.log "convert to resource"
    projectRoot = atom.project.rootDirectory.path
    walk = require 'walkdir'
    fs = require 'fs'
    possibleConversionFiles = []
    emitter = walk(projectRoot)
    emitter.on "file",(filename,stat) ->
      possibleConversionFiles.push filename  if /.*\.resource$/.test(filename)
      return

    zipFiles = []

    emitter.on "end", ->
      console.log possibleConversionFiles
      #narrow down the possible files to only those which are zips
      count = 0
      for possibleConversionFile, i in possibleConversionFiles
        #look at the -meta.xml on each file
        fs.readFile possibleConversionFile+'-meta.xml', (err,data) ->
          count++
          if Buffer.isBuffer(data)
            console.log 'isbuffer'
            data = data.toString('utf8')
          console.log data
          zipFiles.push possibleConversionFile if /<contentType>(application\/zip|application\/x-zip-compressed)<\/contentType>/.test(data)
          if count is possibleConversionFiles.length
            if zipFiles.length
              displayZipFiles zipFiles
              console.log zipFiles
          return
      return

    displayZipFiles = (zipFiles) ->
     menuView: new AtomSfdcBaMenuChoicesView(zipFiles)
     console.log menuView
     atom.workspaceView.append(menuView)
