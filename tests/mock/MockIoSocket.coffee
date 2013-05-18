
class MockIoSocket
  constructor: (@events={})->
    #event hooks
    @values = {}
    self = this
    @socket = connect: (callback) ->
      self.connected = true
      self.trigger 'connect'
      callback?()

  disconnect: ->
    @connected = false
    @trigger 'disconnect'

  on: (action, callback) ->
    @events[action] = callback

  send: (message, callback) ->
    @emit 'message', message, callback

  emit: (action, data, callback) ->
    @onEmit? action, data, callback

  set: (key, value, callback) ->
    @values[key] = value
    callback?()

  get: (key, callback) ->
    callback @values[key]

  #####
  #Test methods (should only be used by test classes

  trigger: (action) ->
    args = [].slice.call(arguments, 1)
    #console.log "Triggering #{action} for", args
    @events[action]?.apply this, args

exports.MockSocket = MockIoSocket
