open = require 'open'

module.exports =
class PageLocalizer
  _replaced = []

  @launchit: (url) ->
    open url
