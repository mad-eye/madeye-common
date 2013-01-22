
class MockIoSocket
  constructor: (@events={})->
    #event hooks

  connect: (callback) ->
    @trigger 'connect'
    callback?()

  disconnect: ->
    @disconnected = true
    @trigger 'disconnect'

  on: (action, callback) ->
    @events[action] = callback

  send: (message, callback) ->
    @emit 'message', message, callback

  emit: (action, data, callback) ->
    @onEmit? action, data, callback

  #####
  #Test methods (should only be used by test classes

  trigger: (action) ->
    args = [].slice.call(arguments, 1)
    console.log "Triggering #{action} for", args
    @events[action]?.apply this, args

exports.MockSocket = MockIoSocket
