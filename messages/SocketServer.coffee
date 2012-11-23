browserChannel = require('browserchannel').server
connect = require('connect')
uuid = require 'node-uuid'
{ChannelMessage, messageAction, messageMaker} = require './ChannelMessage'

class SocketServer
  constructor: (@controller) ->
    @liveSockets = {} # {projectId: socket}, to look sockets up for apogee-dementor communication
    @projectIdMap = {} # {socketId:projectId}, to look up entries in liveSockets for deletion
    @sentMessages = {}
    @registeredCallbacks = {}

  listen: (bcPort) ->
    @server = connect(
      browserChannel (socket) =>
        console.log "Found socket", socket
        @connect(socket)
    ).listen(bcPort)
    console.log 'Echo server listening on localhost:' + bcPort

  connect: (@socket) ->
    console.log "New socket: #{socket.id} from #{socket.address}"

    socket.on 'message', (message) =>
      console.log "Received message", message
      if message.action == messageAction.HANDSHAKE
        @attachSocket socket, message.projectId
        return
      else if message.action == messageAction.CONFIRM
        delete @sentMessages[message.receivedId]
        return
      #Check for any callbacks waiting for a response.
      if message.replyTo?
        #console.log "Checking registered callback to #{message.replyTo}"
        callback = @registeredCallbacks[message.replyTo]
        if callback
          #console.log "Invoking registered callback to #{message.replyTo}", callback
          if message.error
            callback {error: message.error}
          else
            callback null, message
        return
        #TODO: Should this be the end of the message?  Do we ever need to route replies?
      @controller?.route message, (err, replyMessage) ->
        if err
          @send socket, messageMaker.errorMessage err.message
        else
          @send socket, replyMessage

      if message.important
        @send socket, messageMaker.confirmationMessage message

    socket.on 'close', (reason) =>
      @detachSocket socket
      console.log "Socket #{socket.id} disconnected (#{reason})"

  attachSocket: (socket, projectId) ->
    @projectIdMap[socket.id] = projectId
    @liveSockets[projectId] = socket

  detachSocket: (socket) ->
    projectId = @projectIdMap[socket.id]
    delete @liveSockets[projectId] if projectId
    delete @projectIdMap[socket.id]

  send: (socket, message) ->
    socket.send message
    if message.important
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
