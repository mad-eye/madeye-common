assert = require 'assert'
uuid = require 'node-uuid'
{SocketServer} = require '../../messages/SocketServer'
{ChannelMessage} = require '../../messages/ChannelMessage'
{MockSocket} = require '../../mock/MockSocket'

describe 'SocketServer', ->
  projectId = uuid.v4()
  socketServer = socket = null

  describe 'attachSocket', ->
    before ->
      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.attachSocket socket, projectId
    it 'should store sockets by both socket.id and projectId', ->
      assert.equal socket, socketServer.liveSockets[projectId]
    it 'should be cleaned out by @detachSocket', ->
      socketServer.detachSocket socket
      assert.equal socketServer.liveSockets[projectId], null

  describe 'connect', ->
    before ->
      handshakeMessage = new ChannelMessage(ChannelMessage.HANDSHAKE)
      handshakeMessage.projectId = projectId

      socketServer = new SocketServer()
      socket = new MockSocket()
      socketServer.connect socket
      socket.receive handshakeMessage
    it 'should store socket via projectId', ->
      assert.equal socket, socketServer.liveSockets[projectId]

    it 'should direct tells to the right place', ->
      message = ChannelMessage.fileRequestMessage uuid.v4()
      sentMessages = []
      socket.onsend = (msg) ->
        console.log "Socket is sending message #{msg.id}"
        sentMessages.push msg
      socketServer.tell projectId, message
      assert.equal sentMessages.length, 1
      assert.equal sentMessages[0], message


