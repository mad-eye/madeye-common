uuid = require 'node-uuid'
{Settings} = require '../Settings'
{BCSocket} = require 'browserchannel'
{ChannelMessage, messageAction, messageMaker} = require './ChannelMessage'

#WARNING: Must call @destroy when done to close the channel.
class SocketClient
  constructor: () ->
    @sentMessages = {}
    @registeredCallbacks = {}

  destroy: ->
    @socket.close() if @socket?
    @socket = null

  handleMessage: (message) ->
    console.log "Client received message #{message.id}"
    if message.action == messageAction.CONFIRM
      delete @sentMessages[message.receivedId]
    #Check for any callbacks waiting for a response.
    else if message.replyTo?
      console.log "Checking registered callback to #{message.replyTo}"
      callback = @registeredCallbacks[message.replyTo]
      if message.error
        callback? {error: message.error}
      else
        console.log "Invoking registered callback to #{message.replyTo}", callback
        callback? null, message
      return
      #TODO: Should this be the end of the message?  Do we ever need to route replies?
    if @onMessage
      @onMessage message

  openConnection: (@projectId, socket) ->
    console.log "opening connection"
    @socket = socket ? new BCSocket "http://#{Settings.bcHost}:#{Settings.bcPort}/channel", reconnect:true
    @completeSocket @socket
      

  send: (message, callback) ->
    message.projectId = @projectId
    console.log "Client sending message", message
    @socket.send message
    @sentMessages[message.id] = message
    @registeredCallbacks[message.id] = callback

  completeSocket: (socket) ->
    @socket.onopen = =>
      @send messageMaker.handshakeMessage()
    @socket.onmessage = (message) =>
      console.log 'Socket (client) received message', message
      @handleMessage message
    @socket.onerror = (message) =>
      console.log "Socket (client) received error" , message
    @socket.onclose = (message) =>
      console.log "closing time:", message

  
exports.SocketClient = SocketClient
