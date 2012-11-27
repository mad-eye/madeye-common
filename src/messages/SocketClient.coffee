uuid = require 'node-uuid'
{Settings} = require '../Settings'
{BCSocket} = require 'browserchannel'
{messageAction, messageMaker} = require './ChannelMessage'

#TODO: Extract the shared logic of this and SocketServer into another class.
#WARNING: Must call @destroy when done to close the channel.
class SocketClient
  constructor: (@controller) ->
    @sentMessages = {}
    @registeredCallbacks = {}

  destroy: ->
    @socket.close() if @socket?
    @socket = null

  handleMessage: (message) ->
    console.log "Client received message #{message.id}"
    @controller?.route message, (err, replyMessage) =>
      console.warn "Callback invoked without error or replyMessage" unless err? or replyMessage?
      if err
        console.error "Replying with error: #{err.message}"
        @send messageMaker.errorMessage err.message
      else if replyMessage
        #console.log "Replying with message:", replyMessage
        @send replyMessage
    #Check for any callbacks waiting for a response.
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

  openConnection: (@projectId, socket) ->
    console.log "opening connection"
    @socket = socket ? new BCSocket "http://#{Settings.bcHost}:#{Settings.bcPort}/channel", reconnect:true
    @completeSocket @socket
      

  send: (message, callback) ->
    message.projectId = @projectId
    console.log "Client sending message", message
    @socket.send message, (err) ->
      if err
        console.error "Error delivering message #{message.id}:", err
        #TODO: Should retry delivery?
      else
        #console.log "Message #{message.id} delivered to server."
        delete @sendMessages[message.id]
    if message.shouldConfirm
      #console.log "Storing message #{message.id} for confirmation."
      @sentMessages[message.id] = message
    @registeredCallbacks[message.id] = callback

  completeSocket: (socket) ->
    @socket.onopen = =>
      @send messageMaker.handshakeMessage()
    @socket.onmessage = (message) =>
      console.log 'Socket (client) received message', message
      @handleMessage message
    @socket.onerror = (errorMsg, errorCode) ->
      console.error "Error on socket:", msg, errCode
      throw new Error msg
    @socket.onclose = (message) =>
      console.log "closing time:", message

  
exports.SocketClient = SocketClient
