_ = require 'underscore'
uuid = require 'node-uuid'

#Initialize with callbacks 'onopen', 'onmessage', etc
#also have 'onsend', which is called on send.
class MockSocket
  constructor: (callbacks) ->
    @id = uuid.v4()
    @address = "192.168.0.0"
    @setState @CONNECTING
    _.extend(this, callbacks)
    @options = {}
    @headers = {}


  setState: (state) ->
    oldState = @readyState
    @readyState = state
    @['onopen']?() if @readyState == @OPEN && oldState != @OPEN
    @['onclose']?() if @readyState == @CLOSED && oldState != @CLOSED

  completeConnection: ->
    @setState @OPEN

  send: (message) ->
    @onsend message if @onsend?

  receive: (message) ->
    @onmessage message if @onmessage?

  open: ->
    throw new Error 'Already open' unless @readyState is @CLOSED
    @setState @CONNECTING

  close: ->
    @setState @CLOSED

  on: (action, callback) ->
    @["on#{action}"] = callback

MockSocket.prototype['CONNECTING'] = MockSocket['CONNECTING'] = MockSocket.CONNECTING = 0
MockSocket.prototype['OPEN'] = MockSocket['OPEN'] = MockSocket.OPEN = 1
MockSocket.prototype['CLOSING'] = MockSocket['CLOSING'] = MockSocket.CLOSING = 2
MockSocket.prototype['CLOSED'] = MockSocket['CLOSED'] = MockSocket.CLOSED = 3


exports.MockSocket = MockSocket
