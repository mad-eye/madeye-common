browserChannel = require('browserchannel').server
connect = require('connect')
uuid = require 'node-uuid'
{messageAction, messageMaker} = require './messages'
{Settings} = require '../Settings'
{errors} = require '../errors'

#TODO: Extract the shared logic of this and SocketClient into another class.
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
    @server?.close()
    @server = null
    @initialize()


  listen: (bcPort) ->
    @server = connect(
      browserChannel (socket) =>
        @connect socket
    ).listen(bcPort)
    console.log 'SocketServer listening on localhost:' + bcPort

  connect: (socket) ->
    console.log "New socket: #{socket.id} from #{socket.address}"

    socket.on 'message', (message) =>
      console.log "Socket #{socket.id} sent message #{message.id}"
      console.error "Missing controller!" unless @controller
      @handleMessage message, socket

    socket.on 'error', (errorMsg, errorCode) ->
      console.error "Error on socket:", msg, errCode
      throw new Error msg

    socket.on 'close', (reason) =>
      @detachSocket socket
      console.log "Socket #{socket.id} disconnected (#{reason})"

  handleMessage: (message, socket) ->
    #console.log "Server received message", message
    if message.action == messageAction.HANDSHAKE
      console.log "Receiving handshake for project #{message.projectId}"
      @attachSocket socket, message.projectId
      @onHandshake? message.projectId
      replyMessage = messageMaker.replyMessage message
      @send socket, replyMessage
      return

    #Check for any callbacks waiting for a response.
    else if message.replyTo?
      callback = @registeredCallbacks[message.replyTo]
      if callback
        #console.log "Invoking registered callback to #{message.replyTo}", callback
        if message.error
          callback message.error
        else
          callback null, message
        delete @registeredCallbacks[message.replyTo]
      return
      #TODO: Should this be the end of the message?  Do we ever need to route replies?

    else
      @controller?.route message, (err, replyMessage) =>
        console.warn "Callback invoked without error or replyMessage" unless err? or replyMessage?
        if err
          console.error "Replying with error: #{err.message}"
          @send socket, messageMaker.errorMessage err, message.id
        else if replyMessage
          #console.log "Replying with message:", replyMessage
          @send socket, replyMessage

  attachSocket: (socket, projectId) ->
    @projectIdMap[socket.id] = projectId
    @liveSockets[projectId] = socket

  detachSocket: (socket) ->
    projectId = @projectIdMap[socket.id]
    delete @liveSockets[projectId] if projectId
    delete @projectIdMap[socket.id]

  send: (socket, message) =>
    console.log "Server sending message #{message.id} to socket #{socket.id}"
    if message.shouldConfirm
      console.log "Storing message #{message.id} for confirmation."
    @sentMessages[message.id] = message
    socket.send message, (err) =>
      if err
        console.error "Error delivering message #{message.id}:", err
        #TODO: Should retry delivery?
      else
        console.log "Message #{message.id} delivered to client."
        delete @sentMessages[message.id]


  #callback = (err, data) ->,
  tell: (projectId, message, callback) ->
    console.log "Sending message to #{projectId}:", message
    socket = @liveSockets[projectId]
    unless socket
      callback?(errors.new 'CONNECTION_CLOSED')
      return
    @registeredCallbacks[message.id] = callback
    @send socket, message


exports.SocketServer = SocketServer
