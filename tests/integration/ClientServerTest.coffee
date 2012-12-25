_ = require 'underscore'
assert = require 'assert'
uuid = require 'node-uuid'
connect = require 'connect'
browserChannel = require('browserchannel').server
{BCSocket} = require 'browserchannel'
{SocketClient} = require '../../src/messages/SocketClient'
{SocketServer} = require '../../src/messages/SocketServer'
{messageAction, messageMaker} = require '../../src/messages/messages'
{Settings} = require '../../src/Settings'

#TODO: Clean up the redundancy here.  One problem is that often the setup is slightly different, and needs to call the done() method.

## Tests

port = Settings.bcPort

newServer = ->
  server = new SocketServer
  server.listen ++port
  server.receivedMessages = []
  server.controller = { route: (msg, callback) ->
    server.receivedMessages.push msg
    callback? null, messageMaker.replyMessage msg
  }
  return server

newSocket = ->
  new BCSocket "http://localhost:#{port}/channel"

newClient = (projectId, controller) ->
  client = new SocketClient newSocket(), controller
  client.projectId = projectId
  return client

#hooks:
#  onmessage : (msg) -> ...
#  onopen : -> ...
makeSocket = (hooks) ->
  socket = newSocket()
  socket.onerror = (msg, errCode) ->
    console.error "Error on socket:", msg, errCode
    throw new Error msg
  _.extend(socket, hooks)
  return socket


describe 'SocketServerClient:', ->
    
  #XXX: Find way to destroy server after (in-between?) tests.
  message = null
  describe 'socket', ->
    projectId = uuid.v4()
    server = null
    before ->
      server = newServer()
      message = messageMaker.handshakeMessage projectId
    after ->
      server.destroy()

    it 'should be allowed to connect', (done) ->
      socket = makeSocket
        onmessage: (msg) ->
          console.log "Client receiving message", msg.id
          assert.ok msg
          assert.equal msg.replyTo, message.id
          done()
      socket.send message

    it 'should be stored on handshake', (done) ->
      server.onHandshake = (projId) ->
        assert.equal projId, projectId
        assert.ok @liveSockets[projId]
        done()
      makeSocket
        onopen: ->
          @send message


  describe 'SocketClient', ->
    projectId = uuid.v4()
    server = null
    before ->
      server = newServer()
    after ->
      server.destroy()
    afterEach ->
      server.onHandshake = null

    it 'should set projectId on handshake ', (done) ->
      server.onHandshake = (projId) ->
        assert.equal projId, projectId
        assert.ok @liveSockets[projId]
        done()
      client = newClient(projectId)
      message = messageMaker.handshakeMessage()
      client.send message

    it 'should trigger callback on message', (done) ->
      client = newClient(projectId)
      message = messageMaker.addFilesMessage [{
        path: 'some/path'
        isDir: false
      }]
      client.send message, (err, msg) ->
        assert.equal err, null
        assert.ok msg
        assert.equal msg.replyTo, message.id
        done()
      

  describe 'sending messages to client', ->
    projectId = uuid.v4()
    fileId = uuid.v4()
    server = null
    before (done) ->
      server = newServer()
      server.onHandshake = (projId) ->
        console.log "Got handshake for #{projId}"
        done()
      controller = route: (msg, callback) ->
        console.log "Calling client.controller callback."
        if msg.action == messageAction.REQUEST_FILE
          replyMsg = messageMaker.replyMessage msg
          callback null, replyMsg
      client = newClient(projectId, controller)
      client.send messageMaker.handshakeMessage()

    after ->
      server.destroy()
    afterEach ->
      server.onHandshake = null

    it 'should trigger tell callback', (done) ->
      message = messageMaker.requestFileMessage(fileId)
      server.tell projectId, message, (err, responseMsg) ->
        console.log "Calling server.tell callback."
        assert.equal err, null
        assert.ok responseMsg
        assert.equal responseMsg.replyTo, message.id
        done()

  describe 'reconnecting after close', ->
    projectId = uuid.v4()
    server = null
    before (done) ->
      server = newServer()
      controller = { route: (msg, callback) ->
        #console.log "Routing message (has callback: #{callback?}):", msg.id
        #callback? null, null
      }
      server.controller = controller
      server.onHandshake = (projId) ->
        console.log "Got handshake for #{projId}"
        done()
      controller = route: (msg, callback) ->
        console.log "Calling client.controller callback."
        callback null, null
      client = newClient(projectId, controller)
      client.send messageMaker.handshakeMessage()

    after ->
      server.destroy()
    afterEach ->
      server.onHandshake = null

    it 'should reopen socket'
    it 'should resend handshake'

  describe 'closing down SocketClient', ->
    projectId = null
    server = client = socket = null
    before ->
      server = newServer()

    beforeEach (done) ->
      server.onHandshake = (projId) ->
        console.log "Got handshake for #{projId}"
        done()
      projectId = uuid.v4()
      client = newClient projectId
      client.send messageMaker.handshakeMessage()

    after ->
      server.destroy()
    afterEach ->
      server.onHandshake = null

    it "should shut down gracefully", (done) ->
      client.destroy done
    it "should close socket on SocketServer"

