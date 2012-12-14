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
    it 'should store sockets by both socket.id and projectId', ->
      assert.equal socket, socketServer.liveSockets[projectId]
    it 'should be cleaned out by @detachSocket', ->
      socketServer.detachSocket socket
      assert.equal socketServer.liveSockets[projectId], null

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
    before ->
      projectId = uuid.v4()
      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.attachSocket socket, projectId
    it 'should give appropriate error when socket is missing', (done) ->
      newProjId = uuid.v4()
      message = messageMaker.requestFileMessage uuid.v4()
      socketServer.tell newProjId, message, (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err.type, errorType.CONNECTION_CLOSED, "Error should be CONNECTION_CLOSED"
        done()




