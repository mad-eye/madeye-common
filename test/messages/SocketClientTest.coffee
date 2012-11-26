assert = require 'assert'
uuid = require 'node-uuid'
{SocketClient} = require '../../messages/SocketClient'
{MockSocket} = require '../../mock/MockSocket'
{ChannelMessage, messageAction, messageMaker} = require '../../messages/ChannelMessage'


describe 'SocketClient', ->
  socket = socketClient = null
  projectId = uuid.v4()
  
  describe 'openConnection', ->
    before ->
      socket = new MockSocket()
      socketClient = new SocketClient()
      socketClient.openConnection projectId, socket
    it 'should set socket.onopen', ->
      assert.ok socket.onopen
    it 'should set socket.onmessage', ->
      assert.ok socket.onerror
    it 'should set socket.onerror', ->
      assert.ok socket.onerror
    it 'should set socket.onclose', ->
      assert.ok socket.onclose

  describe 'destroy', ->
    before ->
      socket = new MockSocket()
      socketClient = new SocketClient()
      socketClient.openConnection projectId, socket
      socketClient.destroy()
    it 'should close socket', ->
      assert.equal socket.readyState, MockSocket.CLOSED
    
  describe 'send', ->
    message = messageMaker.addFilesMessage()
    sentMessages = []
    before ->
      socket = new MockSocket()
      socket.onsend = (msg) ->
        sentMessages.push msg
      socketClient = new SocketClient()
      socketClient.openConnection projectId, socket
      socketClient.send message
    it 'should set message projectId', ->
      assert.equal message.projectId, projectId
    it 'should have sent the message', ->
      assert.equal sentMessages.length, 1
      assert.equal sentMessages[0], message
    it 'should have saved the message', ->
      assert.equal socketClient.sentMessages[message.id], message

  describe 'handleMessage', ->
    before ->
      socket = new MockSocket()
      socketClient = new SocketClient()
      socketClient.openConnection projectId, socket
    it 'triggers onMessage on receive', ->
      receivedMsg = null
      socketClient.onMessage = (msg) ->
        receivedMsg = msg
      message = messageMaker.requestFileMessage uuid.v4()
      socket.receive message
      assert.equal message, receivedMsg

      


  

