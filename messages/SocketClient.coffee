{Settings} = require './Settings'
{BCSocket} = require 'browserchannel'
uuid = require 'node-uuid'

#WARNING: Must call @destroy when done to close the channel.
class SocketClient
  constructor: (@socket) ->
    unless socket
      @socket = new BCSocket "http://#{Settings.bcHost}:#{Settings.bcPort}/channel", reconnect:true
    console.log "SocketClient constructed with socket", @socket
    @sentMsgs = {}
    @registeredCallbacks = {}

  destroy: ->
    @socket.close() if @socket?
    @socket = null

  handleMessage: (message) ->
    if message.action == ChannelMessage.CONFIRM
      delete @sentMsgs[message.receivedId]
    #Check for any callbacks waiting for a response.
    else if message.replyTo?
      #console.log "Checking registered callback to #{message.replyTo}"
      callback = @registeredCallbacks[message.replyTo]
      if message.error
        callback? {error: message.error}
      else
        #console.log "Invoking registered callback to #{message.replyTo}", callback
        callback? null, message
      return
      #TODO: Should this be the end of the message?  Do we ever need to route replies?
    else
      if @onMessage
        @onMessage message
      else
        console.warn "No onMessage to handle message", message

  openBrowserChannel: (@projectId) ->
    @socket.onopen = =>
      @send new ChannelMessage(ChannelMessage.HANDSHAKE)
      console.log "opening connection"
    @socket.onmessage = (message) =>
      console.log 'ChannelConnector got message', message
      @handleMessage message
    @socket.onerror = (message) =>
      console.log "ChannelConnector got error" , message
    @socket.onclose = (message) =>
      console.log "closing time", message

  send: (message, callback) ->
    message.projectId = @projectId
    @socket.send message
    @sentMsgs[message.id] = message
    @registeredCallbacks[message.id] = callback



exports.SocketClient = SocketClient
