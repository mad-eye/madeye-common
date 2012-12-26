uuid = require 'node-uuid'
flow = require 'flow'
{Settings} = require '../Settings'
{BCSocket} = require 'browserchannel'
{messageAction, messageMaker} = require './messages'
{errors, errorType} = require '../errors'

#TODO: Extract the shared logic of this and SocketServer into another class.
#WARNING: Must call @destroy when done to close the channel.
class SocketClient
  constructor: (@socket, @controller) ->
    @sentMessages = {}
    @registeredCallbacks = {}
    @socket ?= SocketClient.defaultSocket()
    @completeSocket @socket

  destroy: (callback) ->
    @stopHeartbeat()
    @socket?.close()
    @socket = null
    callback?() #An eye towards the future

  handleMessage: (message) ->
    #console.log "Client received message", message.id
    ## REPLY Layer Check for any callbacks waiting for a response.
    if message.replyTo?
      callback = @registeredCallbacks[message.replyTo]
      if message.error
        callback? message.error
      else
        #console.log "Invoking registered callback to #{message.replyTo}"
        callback? null, message
      delete @registeredCallbacks[message.replyTo]
      return
      #XXX: Should this be the end of the message?  Do we ever need to route replies?

    #Give to router to handle other messages.
    @controller?.route message, (err, replyMessage) =>
      #console.warn "Callback invoked without error or replyMessage" unless err? or replyMessage?
      if err
        console.error "Replying with error:", err
        @send messageMaker.errorMessage err, message.id
      else if replyMessage
        @send replyMessage

  send: (message, callback) ->
    unless message?
      console.warn "SocketClient.send trying to send non-object message:", message
      callback? errors.new errorType.MISSING_PARAM
      return
    unless typeof message == 'object'
      console.warn "SocketClient.send trying to send non-object message:", message
      callback? errors.new errorType.INVALID_PARAM
      return
    unless @projectId
      console.warn "SocketClient.send trying to send without a projectId"
      callback? errors.new errorType.MISSING_PARAM
      return
    message.projectId = @projectId
    @registeredCallbacks[message.id] = callback
    if message.shouldConfirm
      @sentMessages[message.id] = message
    #console.log "SocketClient sending message", message
    @socket.send message

  completeSocket: (socket) ->
    return unless socket?
    @socket.onopen = =>
      #This will hopefully re-establish a two-way connection to azkaban.
      #console.log "Reopening socket"
      if @projectId
        @send messageMaker.handshakeMessage(), (err) ->
          console.log "Error in onopen handshake:", err if err
    @socket.onmessage = (message) =>
      @handleMessage message
    @socket.onerror = (msg, errorCode) ->
      console.error "Error on socket:", msg, errCode
      throw new Error msg
    @socket.onclose = (message) =>
      console.log "Closing socket:", message

  startHeartbeat: ->
    @heartbeatHandle = setInterval =>
      @send messageMaker.heartbeatMessage()
    , 1000

  stopHeartbeat: ->
    clearInterval @heartbeatHandle

  @defaultSocket: ->
    socket = new BCSocket "http://#{Settings.bcHost}:#{Settings.bcPort}/channel", reconnect:true

  
exports.SocketClient = SocketClient
