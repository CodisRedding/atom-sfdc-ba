{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'

# [Salesforce]
# Base class for all Salesforce utilities
class Salesforce
  _loginUrl = atom.config.get("atom-sfdc-ba.loginUrl")
  _username = atom.config.get("atom-sfdc-ba.username")
  _password = atom.config.get("atom-sfdc-ba.password")
  _securityToken = atom.config.get("atom-sfdc-ba.securityToken")
  _apiVersion = atom.config.get("atom-sfdc-ba.apiVersion")
  _loggedIn = false
  _conn = null
  _jsforce = null

  constructor: ->
    # This is to allow jsforce to run without
    # warnings that use of eval is evil
    allowUnsafeNewFunction ->
      _jsforce ?= require 'jsforce'

    options =
      loginUrl: _loginUrl
      instanceUrl: ""
      version: _apiVersion

    _conn = new _jsforce.Connection(options)

  getSessionId: ->
    _conn?.accessToken

  getApiVersion: ->
    _apiVersion

  login: (callback) ->
    _conn.login _username, _password + _securityToken, (err, res) ->
      callback(err, res)

module.exports = Salesforce
