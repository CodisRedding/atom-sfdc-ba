sanitizeHtml = require 'sanitize-html'
Promise = require 'bluebird'
request = Promise.promisify(require 'request')
open = require 'open'

module.exports =
class PageLocalizer
  _replaced = []

  @launchit: (url) ->
    open "http://www.google.com", "firefox"

  localize: (pages) ->
    # _replaceCss content for content in pages

  # content = content.replace(element, '<link src=""/>')
  # {!URLFOR(target, id, [inputs], [no override])}
  #
  #  target: You can replace target with a URL or action, s-control or static
  #           resource.
  #
  #  id:     This is id of the object or resource name (string type) in support
  #           of the provided target.
  #
  #  inputs: Any additional URL parameters you need to pass you can use this
  #           parameter. you will to put the URL parameters in brackets and
  #           separate them with commas
  #
  #           ex : value[param1="value1", param2="value2"]
  #
  #  no override: A Boolean value which defaults to false, it applies to
  #               targets for standard Salesforce pages. Replace "no override"
  #               with "true" when you want to display a standard Salesforce
  #               page regardless of whether you have defined an override for
  #               it elsewhere.
  @replaceCss: (content) ->

    # look for stylesheet entries
    while content.indexOf('<apex:stylesheet') >= 0
      styleStart = content.indexOf('<apex:stylesheet')
      styleEnd = content.indexOf('/>', styleStart)

      # stylesheet entry found
      if styleEnd and (styleEnd > styleStart)
        styleElement = content.substr(styleStart, (styleEnd + 2) - styleStart)
        console.debug 'styleElement: ', styleElement
        content = content.replace(styleElement, '[REPLACED]')

        # look for URLFOR entries
        while styleElement and styleElement.indexOf('URLFOR(') >= 0
          urlforStart = styleElement.indexOf('URLFOR(')
          urlforEnd = styleElement.indexOf(')', urlforStart)

          # found URLFOR entry
          if urlforEnd and (urlforEnd > urlforStart)
            urlforElement = styleElement.substr(urlforStart, (urlforEnd + 1) - urlforStart)
            console.debug 'urlforElement: ', urlforElement
            styleElement = styleElement.replace(urlforElement, '[REPLACED]')

            # look for resource entries
            while urlforElement and (urlforElement.indexOf('$Resource.') >= 0)
              resourceStart = urlforElement.indexOf('$Resource.')
              resourceEnd = urlforElement.indexOf(',', resourceStart)

              #found resource
              resourceStart += 10
              if resourceEnd and (resourceEnd > resourceStart)
                resourceElement = urlforElement.substr(resourceStart, resourceEnd - resourceStart).trim()
                console.debug 'resourceElement: ', resourceElement
                urlforElement = urlforElement.replace("$Resource.#{resourceElement}", '[REPLACED]')
              else
                resourceEnd = urlforElement.indexOf(')', resourceStart)
                if resourceEnd and (resourceEnd > resourceStart)
                  resourceElement = urlforElement.substr(resourceStart, resourceEnd - resourceStart).trim()
                  console.debug 'resourceElement: ', resourceElement
                  urlforElement = urlforElement.replace("$Resource.#{resourceElement}", '[REPLACED]')

              if urlforElement.indexOf(',') >= 0
                resourceExtStart = urlforElement.indexOf(',')
                resourceExtEnd = urlforElement.indexOf(')', resourceExtStart)

                if resourceExtEnd and (resourceExtEnd > resourceExtStart)
                  resourceExtElement = urlforElement.substr(resourceExtStart + 1, (resourceExtEnd - 1) - resourceExtStart).trim()
                  console.debug 'resourceExtElement: ', resourceExtElement
                  urlforElement = urlforElement.replace(resourceExtElement, '[REPLACED]')

    console.log 'content: %s', content
