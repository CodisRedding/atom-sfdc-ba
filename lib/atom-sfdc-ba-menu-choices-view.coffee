class AtomSfdcBaMenuChoicesView extends View
  @content: ->
      @ul out: "list"

  initialize = (menuChoices) ->
    for menuChoice in menuChoices
      @list.append("<li>#{menuChoice}</li>")
