uuid = require 'node-uuid'
{Settings} = require '../Settings'
{BCSocket} = require 'browserchannel'
{messageAction, messageMaker} = require './ChannelMessage'

#TODO: Extract the shared logic of this and SocketServer into another class.
#WARNING: Must call @destroy when done to close the channel.
class SocketClient
  constructor: (@socket, @controller) ->
    @sentMessages = {}
    @registeredCallbacks = {}
    @socket ?= SocketClient.defaultSocket()
    @completeSocket @socket

  destroy: ->
    @socket?.close()
    @socket = null

  handleMessage: (message) ->
    console.log "Client received message #{message.id}"
    ## Handle incoming Error Layer
    if message.error?
      console.error "Received error message:", message
      @handleError? message.error
      return
    ## Route Layer
    @controller?.route message, (err, replyMessage) =>
      console.warn "Callback invoked without error or replyMessage" unless err? or replyMessage?
      if err
        console.error "Replying with error: #{err.message}"
        @send messageMaker.errorMessage err.message
      else if replyMessage
        #console.log "Replying with message:", replyMessage
        @send replyMessage
    ## REPLY Layer Check for any callbacks waiting for a response.
    if message.replyTo?
      console.log "Checking registered callback to #{message.replyTo}"
      callback = @registeredCallbacks[message.replyTo]
      if message.error
        callback? {error: message.error}
      else
        #console.log "Invoking registered callback to #{message.replyTo}", callback
        callback? null, message
      return
      #TODO: Should this be the end of the message?  Do we ever need to route replies?

  send: (message, callback) ->
    unless message? && typeof message == 'object'
      throw new Error "SocketClient.send trying to send non-object message:", message
    message.projectId = @projectId
    #console.log "Client sending message", message
    @registeredCallbacks[message.id] = callback
    @socket.send message, (err) =>
      if err
        console.error "Error delivering message #{message.id}:", err
        callback err
        #TODO: Should retry delivery?
      else
        console.log "Message #{message.id} delivered to server."
        delete @sentMessages[message.id]
    if message.shouldConfirm
      #console.log "Storing message #{message.id} for confirmation."
      @sentMessages[message.id] = message

  completeSocket: (socket) ->
    return unless socket?
    @socket.onopen = ->
      console.log "Opened socket."
    @socket.onmessage = (message) =>
      #console.log 'Socket (client) received message', message
      @handleMessage message
    @socket.onerror = (errorMsg, errorCode) ->
      console.error "Error on socket:", msg, errCode
      throw new Error msg
    @socket.onclose = (message) =>
      console.log "closing socket:", message

  @defaultSocket: ->
    socket = new BCSocket "http://#{Settings.bcHost}:#{Settings.bcPort}/channel", reconnect:true

  
exports.SocketClient = SocketClient
