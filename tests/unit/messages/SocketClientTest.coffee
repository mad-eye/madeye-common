assert = require 'assert'
uuid = require 'node-uuid'
{SocketClient} = require '../../../src/messages/SocketClient'
{MockSocket} = require '../../mock/MockSocket'
{messageAction, messageMaker} = require '../../../src/messages/messages'
{errors, errorType} = require '../../../src/errors'

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
    it 'should direct onmessage to @handleMessage'
    it 'should set socket.onerror', ->
      assert.ok socket.onerror
    it 'should direct onerror to @handleError'


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
    message = null
    sentMessages = []
    before ->
      message = messageMaker.addFilesMessage()
      socket = new MockSocket()
      socket.onsend = (msg) ->
        sentMessages.push msg
      socketClient = new SocketClient(socket)
    beforeEach ->
      socketClient.projectId = projectId
      
    it 'should have sent the message', ->
      socketClient.send message
      assert.equal sentMessages.length, 1
      assert.equal sentMessages[0], message

    it 'should trigger the callback on response', (done) ->
      reply = null
      socket.onsend = (msg) ->
        console.log "Socket found outgoing message #{msg.id}"
        reply = messageMaker.replyMessage msg
        @receive reply
      socketClient.send message, (err, replyMsg) ->
        assert.equal err, null, "Should not return an error."
        assert.ok replyMsg, "Should return a reply message."
        assert.equal replyMsg, reply, "Should return the right message."
        done()

    it 'should trigger the callback on error in response', (done) ->
      error = errors.new errorType.MISSING_PARAM
      socket.onsend = (msg) ->
        errorMsg = messageMaker.errorMessage error, msg.id
        @receive errorMsg
      socketClient.send message, (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err, error
        done()

    it 'should callback an error when sent object is null', (done) ->
      socketClient.send null, (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err.type, errorType.MISSING_PARAM
        done()
        
    it 'should callback an error when sent object is not an object', (done) ->
      socketClient.send 'shouldnt be a string', (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err.type, errorType.INVALID_PARAM
        done()
        
    it 'should callback an error if projectId is not set fweep', (done) ->
      console.log "Sending test message", message
      socketClient.projectId = null
      socketClient.send message, (err, replyMsg) ->
        assert.equal replyMsg, null, "Should not return a replyMsg"
        assert.ok err, "Should return an error."
        assert.equal err.type, errorType.MISSING_PARAM
        done()

  describe 'receive message', ->
    message = null
    before ->
      message = messageMaker.addFilesMessage []
      socket = new MockSocket()
      socketClient = new SocketClient(socket)
    it 'triggers controller on receive', (done) ->
      socketClient.controller = {
        route : (msg, callback) ->
          assert.equal msg, message
          done()
      }
      socket.receive message
    it 'should clear callbacks when a reply message is received', ->
      replyMessage = messageMaker.replyMessage message
      socketClient.registeredCallbacks[message.id] = (err, replyMsg) ->
      socket.receive replyMessage
      assert.equal null, socketClient.registeredCallbacks[message.id]

  describe 'handleMessage', ->
    message = null
    before ->
      projectId = uuid.v4()
      socket = new MockSocket()
      socketClient = new SocketClient(socket)
      socketClient.projectId = projectId
      message = messageMaker.addFilesMessage []

    it 'should trigger callbacks on a reply message', (done) ->
      reply = messageMaker.replyMessage message
      socketClient.registeredCallbacks[message.id] = (err, replyMsg) ->
        assert.equal err, null
        assert.ok replyMsg
        assert.equal replyMsg, reply
        done()
      socketClient.handleMessage reply, socket

    it 'should trigger callbacks on an error message', (done) ->
      error = errors.new errorType.MISSING_PARAM
      errorMsg = messageMaker.errorMessage error, message.id
      socketClient.registeredCallbacks[message.id] = (err, replyMsg) ->
        assert.equal replyMsg, null
        assert.ok err
        assert.equal err, error
        done()
      socketClient.handleMessage errorMsg, socket
    
    it 'should direct other requests to the controller', (done) ->
      message = messageMaker.addFilesMessage []
      controller =
        route: (msg, callback) ->
          assert.ok msg
          assert.equal msg, message
          done()
      socketClient.controller = controller
      socketClient.handleMessage message, socket

    it 'should send an error message if controller replies with an error', (done) ->
      message = messageMaker.addFilesMessage []
      error = errors.new errorType.MISSING_PARAM
      controller =
        route: (msg, callback) ->
          callback error
      socketClient.controller = controller
      socket.onsend = (msg) ->
        console.log "Socket found outgoing message #{msg.id}"
        assert.ok msg
        assert.equal msg.error, error
        assert.equal msg.replyTo, message.id
        done()
      socketClient.handleMessage message, socket

    it 'should send a reply message if controller replies with a message', (done) ->
      message = messageMaker.addFilesMessage []
      reply = messageMaker.replyMessage message
      controller =
        route: (msg, callback) ->
          callback null, reply
      socketClient.controller = controller
      socket.onsend = (msg) ->
        console.log "Socket found outgoing message #{msg.id}"
        assert.ok msg
        assert.equal msg, reply
        done()
      socketClient.handleMessage message, socket
      

