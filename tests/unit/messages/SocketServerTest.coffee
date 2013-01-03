assert = require 'assert'
uuid = require 'node-uuid'
{SocketServer} = require '../../../src/messages/SocketServer'
{messageAction, messageMaker} = require '../../../src/messages/messages'
{MockSocket} = require '../../mock/MockSocket'
{errors, errorType} = require '../../../src/errors'

describe 'SocketServer', ->
  projectId = null
  socketServer = socket = null

  describe 'attachSocket', ->
    before ->
      projectId = uuid.v4()
      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.attachSocket socket, projectId
    it 'should store sockets by projectId', ->
      assert.equal socket, socketServer.liveSockets[projectId]
    it 'should store projectId by socket.id', ->
      assert.equal socketServer.projectIdMap[socket.id], projectId

  describe 'detachSocket', ->
    closedProjectId = projectId = null
    before ->
      projectId = uuid.v4()
      socketServer = new SocketServer closeProject : (projId) ->
        console.log "Calling closeProject"
        closedProjectId = projId
      socket = new MockSocket()
      socketServer.attachSocket socket, projectId
      socketServer.detachSocket socket

    it 'should remove socket.id from projectIdMap', ->
      assert.equal socketServer.projectIdMap[socket.id], null

    it 'should remove projectId from liveSockets', ->
      assert.equal socketServer.liveSockets[projectId], null

    it 'should close project', ->
      assert.equal closedProjectId, projectId

  describe 'detachSocket when the socket has been replaced fweep', ->
    closedProjectId = projectId = null
    socket2 = null
    before ->
      projectId = uuid.v4()
      socketServer = new SocketServer closeProject : (projId) ->
        console.log "Calling closeProject"
        closedProjectId = projId
      socket = new MockSocket()
      socketServer.attachSocket socket, projectId
      socket2 = new MockSocket()
      socketServer.attachSocket socket2, projectId
      socketServer.detachSocket socket

    it 'should still remove socket.id from projectIdMap', ->
      assert.equal socketServer.projectIdMap[socket.id], null

    it 'should not remove projectId from liveSockets', ->
      assert.equal socketServer.liveSockets[projectId], socket2

    it 'should not close project', ->
      assert.equal closedProjectId, null


  describe 'connect', ->
    before (done) ->
      projectId = uuid.v4()
      handshakeMessage = messageMaker.handshakeMessage()
      handshakeMessage.projectId = projectId

      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.connect socket
      socketServer.onHandshake = ->
        console.log "Receiving handshake"
        done()
      socket.receive handshakeMessage
    it 'should store socket via projectId', ->
      assert.equal socket, socketServer.liveSockets[projectId]

    it 'should direct tells to the right place', ->
      message = messageMaker.requestFileMessage uuid.v4()
      sentMessages = []
      socket.onsend = (msg) ->
        console.log "Socket is sending message #{msg.id}"
        sentMessages.push msg
      socketServer.tell projectId, message
      assert.equal sentMessages.length, 1
      assert.equal sentMessages[0], message

  describe 'tell', ->
    message = null
    before ->
      projectId = uuid.v4()
      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.connect socket
      socketServer.attachSocket socket, projectId
      message = messageMaker.requestFileMessage uuid.v4()
    it 'should give appropriate error when socket is missing', (done) ->
      newProjId = uuid.v4()
      socketServer.tell newProjId, message, (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err.type, errorType.CONNECTION_CLOSED, "Error should be CONNECTION_CLOSED"
        done()

    it 'should callback error if socket responds with an error', (done) ->
      error = errors.new errorType.MISSING_PARAM
      socket.onsend = (msg) ->
        errorMsg = messageMaker.errorMessage error, msg.id
        @receive errorMsg
      socketServer.tell projectId, message, (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err, error
        done()
        
    it 'should callback the replyMessage if socket responds', (done) ->
      reply = null
      socket.onsend = (msg) ->
        console.log "Socket found outgoing message #{msg.id}"
        reply = messageMaker.replyMessage msg
        @receive reply
      socketServer.tell projectId, message, (err, replyMsg) ->
        assert.equal err, null, "Should not return an error."
        assert.ok replyMsg, "Should return a reply message."
        assert.equal replyMsg, reply, "Should return the right message."
        done()

  describe 'handleMessage', ->
    message = null
    before ->
      projectId = uuid.v4()
      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.connect socket
      socketServer.attachSocket socket, projectId
      message = messageMaker.requestFileMessage uuid.v4()

    it 'should trigger callbacks on a reply message', (done) ->
      reply = messageMaker.replyMessage message
      socketServer.registeredCallbacks[message.id] = (err, replyMsg) ->
        assert.equal err, null
        assert.ok replyMsg
        assert.equal replyMsg, reply
        done()
      socketServer.handleMessage reply, socket

    it 'should trigger callbacks on an error message', (done) ->
      error = errors.new errorType.MISSING_PARAM
      errorMsg = messageMaker.errorMessage error, message.id
      socketServer.registeredCallbacks[message.id] = (err, replyMsg) ->
        assert.equal replyMsg, null
        assert.ok err
        assert.equal err, error
        done()
      socketServer.handleMessage errorMsg, socket
    
    it 'should handle handshakes', (done) ->
      socketServer.onHandshake = (projId) ->
        assert.ok projId
        assert.equal projId, projectId
        done()
      handshake = messageMaker.handshakeMessage projectId
      socketServer.handleMessage handshake, socket

    it 'should direct other requests to the controller', (done) ->
      message = messageMaker.addFilesMessage []
      controller =
        route: (msg, callback) ->
          assert.ok msg
          assert.equal msg, message
          done()
      socketServer.controller = controller
      socketServer.handleMessage message, socket

    it 'should send an error message if controller replies with an error', (done) ->
      message = messageMaker.addFilesMessage []
      error = errors.new errorType.MISSING_PARAM
      controller =
        route: (msg, callback) ->
          callback error
      socketServer.controller = controller
      socket.onsend = (msg) ->
        console.log "Socket found outgoing message #{msg.id}"
        assert.ok msg
        assert.equal msg.error, error
        assert.equal msg.replyTo, message.id
        done()
      socketServer.handleMessage message, socket

    it 'should send a reply message if controller replies with a message', (done) ->
      message = messageMaker.addFilesMessage []
      reply = messageMaker.replyMessage message
      controller =
        route: (msg, callback) ->
          callback null, reply
      socketServer.controller = controller
      socket.onsend = (msg) ->
        console.log "Socket found outgoing message #{msg.id}"
        assert.ok msg
        assert.equal msg, reply
        done()
      socketServer.handleMessage message, socket
      



