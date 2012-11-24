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
    if message.action == messageAction.CONFIRM
      delete @sentMessages[message.receivedId]
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

  openConnection: (@projectId, socket) ->
    console.log "opening connection"
    if socket
      @socket = socket
      @completeSocket socket
    else
      @socket = @makeSocket(Settings.bcHost, Settings.bcPort)

  send: (message, callback) ->
    message.projectId = @projectId
    @socket.send message
    @sentMessages[message.id] = message
    @registeredCallbacks[message.id] = callback

  makeSocket: (host, port) ->
    @socket = new BCSocket "http://#{host}:#{port}/channel", reconnect:true
    @completeSocket @socket

  completeSocket: (socket) ->
    @socket.onopen = =>
      @send messageMaker.handshakeMessage
    @socket.onmessage = (message) =>
      console.log 'ChannelConnector got message', message
      @handleMessage message
    @socket.onerror = (message) =>
      console.log "ChannelConnector got error" , message
    @socket.onclose = (message) =>
      console.log "closing time:", message

  
exports.SocketClient = SocketClient
