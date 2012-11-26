browserChannel = require('browserchannel').server
connect = require('connect')
uuid = require 'node-uuid'
{ChannelMessage, messageAction, messageMaker} = require './ChannelMessage'
{Settings} = require '../Settings'

class SocketServer
  constructor: (@controller) ->
    #console.log "Constructing with controller", @controller
    @initialize()
  
  initialize: ->
    @liveSockets = {} # {projectId: socket}, to look sockets up for apogee-dementor communication
    @projectIdMap = {} # {socketId:projectId}, to look up entries in liveSockets for deletion
    @sentMessages = {}
    @registeredCallbacks = {}

  destroy: ->
    socket.stop() for projectId, socket of @liveSockets
    @server.close()
    @server = null
    @initialize()


  listen: (bcPort) ->
    @server = connect(
      browserChannel (socket) =>
        @connect socket
    ).listen(bcPort)
    console.log 'Socket server listening on localhost:' + bcPort

  connect: (@socket) ->
    console.log "New socket: #{socket.id} from #{socket.address}"

    socket.on 'message', (message) =>
      console.log "Socket #{socket.id} sent message #{message.id}"
      unless @controller
        console.error "Missing controller!"
        throw new Error 'Missing controller!'
      @handleMessage message, socket

    socket.on 'error', (errorMsg, errorCode) ->
      console.error "Error on socket:", msg, errCode
      throw new Error msg

    socket.on 'close', (reason) =>
      @detachSocket socket
      console.log "Socket #{socket.id} disconnected (#{reason})"

  handleMessage: (message, socket) ->
    if message.shouldConfirm
      console.log "Sending confirmation message for #{message.id}"
      @send socket, messageMaker.confirmationMessage message
    if message.action == messageAction.HANDSHAKE
      console.log "Receiving handshake for project #{message.projectId}"
      @attachSocket socket, message.projectId
      return
    else
      @controller.route message, (err, replyMessage) =>
        console.warn "Callback invoked without error or replyMessage" unless err? or replyMessage?
        if err
          console.error "Replying with error: #{err.message}"
          @send socket, messageMaker.errorMessage err.message
        else if replyMessage
          console.log "Replying with message:", replyMessage
          @send socket, replyMessage

    #  else if message.action == messageAction.CONFIRM
    #    delete @sentMessages[message.receivedId]
    #    return
    #  #Check for any callbacks waiting for a response.
    #  if message.replyTo?
    #    console.log "Checking registered callback to #{message.replyTo}"
    #    callback = @registeredCallbacks[message.replyTo]
    #    if callback
    #      #console.log "Invoking registered callback to #{message.replyTo}", callback
    #      if message.error
    #        callback {error: message.error}
    #      else
    #        callback null, message
    #    return
    #    #TODO: Should this be the end of the message?  Do we ever need to route replies?

  attachSocket: (socket, projectId) ->
    @projectIdMap[socket.id] = projectId
    @liveSockets[projectId] = socket

  detachSocket: (socket) ->
    projectId = @projectIdMap[socket.id]
    delete @liveSockets[projectId] if projectId
    delete @projectIdMap[socket.id]

  send: (socket, message) ->
    console.log "Server sending message #{message.id} to socket #{socket.id}"
    socket.send message, (err) ->
      console.log "Message #{message.id} received.  Returned error:", err
    if message.important
      console.log "Storing message #{message.id} for confirmation."
      @sentMessages[message.id] = message

    
  #callback = (err, data) ->, 
  tell: (projectId, message, callback) ->
    console.log "Sending message to #{projectId}:", message
    socket = @liveSockets[projectId]
    unless socket
      callback?({error: 'The project has been closed.'})
      return
    @send socket, message
    @registeredCallbacks[message.id] = callback

  
exports.SocketServer = SocketServer
