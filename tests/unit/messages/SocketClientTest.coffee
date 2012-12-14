assert = require 'assert'
uuid = require 'node-uuid'
{SocketClient} = require '../../../src/messages/SocketClient'
{MockSocket} = require '../../mock/MockSocket'
{messageAction, messageMaker} = require '../../../src/messages/ChannelMessage'

#TODO: Use beforeEach to reduce duplicated code
describe 'SocketClient', ->
  socket = socketClient = null
  projectId = uuid.v4()

  describe 'openConnection', ->
    before ->
      socket = new MockSocket()
      socketClient = new SocketClient(socket)
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
      socketClient = new SocketClient(socket)
      socketClient.destroy()
    it 'should close socket', ->
      assert.equal socket.readyState, MockSocket.CLOSED
    it 'should set socket to null', ->
      assert.equal socketClient.socket, null

  describe 'send', ->
    message = messageMaker.addFilesMessage()
    sentMessages = []
    before ->
      socket = new MockSocket()
      socket.onsend = (msg) ->
        sentMessages.push msg
      socketClient = new SocketClient(socket)
      socketClient.send message
    it 'should have sent the message', ->
      assert.equal sentMessages.length, 1
      assert.equal sentMessages[0], message

  describe 'handleMessage', ->
    before ->
      socket = new MockSocket()
      socketClient = new SocketClient(socket)
    it 'triggers controller on receive', ->
      receivedMsg = null
      socketClient.controller = {
        route : (msg, callback) ->
          receivedMsg = msg
      }
      message = messageMaker.requestFileMessage uuid.v4()
      socket.receive message
      assert.equal message, receivedMsg
    it 'triggers handleError on error message', (done) ->
      errorString = "This is an error!"
      socketClient.handleError = (error) ->
        assert.equal error, errorString
        done()
      socket.receive messageMaker.errorMessage errorString

