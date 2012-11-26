_ = require 'underscore'
assert = require 'assert'
uuid = require 'node-uuid'
connect = require 'connect'
browserChannel = require('browserchannel').server
{BCSocket} = require 'browserchannel'
{SocketClient} = require '../../src/messages/SocketClient'
{SocketServer} = require '../../src/messages/SocketServer'
{ChannelMessage, messageAction, messageMaker} = require '../../src/messages/ChannelMessage'
{Settings} = require '../../src/Settings'

#TODO: Clean up the redundancy here.  One problem is that often the setup is slightly different, and needs to call the done() method.

## Tests

port = Settings.bcPort

newServer = ->
  server = new SocketServer
  server.listen ++port
  return server

newSocket = ->
  new BCSocket "http://localhost:#{port}/channel"

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


describe 'SocketServer:', ->
    
  #XXX: Find way to destroy server after (in-between?) tests.
  describe 'socket', ->
    projectId = uuid.v4()
    server = null
    before ->
      server = newServer()
      controller = { route: (msg, callback) ->
        console.log "Routing message (has callback: #{callback?}):", msg.id
        replyMessage = messageMaker.message
          action: 'test'
          replyTo: msg.id
          shouldConfirm: false
        callback? null, replyMessage
      }
      server.controller = controller
    after ->
      server.destroy()

    it 'should be allowed to connect', (done) ->
      makeSocket
        onopen: ->
          message = messageMaker.message
            action: 'test'
            shouldConfirm: false
          #console.log "Client sending message", message
          @send message
        onmessage: (msg) ->
          console.log "Client receiving message", msg.id
          assert.ok msg
          done()

    it 'should be stored on handshake', (done) ->
      server.onHandshake = (projId) ->
        assert.equal projId, projectId
        assert.ok @liveSockets[projId]
        done()
      makeSocket
        onopen: ->
          message = messageMaker.handshakeMessage()
          message.projectId = projectId
          @send message


  describe 'SocketClient', ->
    projectId = uuid.v4()
    server = null
    before ->
      server = newServer()
      controller = { route: (msg, callback) ->
        console.log "Routing message (has callback: #{callback?}):", msg.id
        replyMessage = messageMaker.message
          action: 'test'
          replyTo: msg.id
          shouldConfirm: false
        callback? null, replyMessage
      }
      server.controller = controller
    after ->
      server.destroy()
    afterEach ->
      server.onHandshake = null

    it 'should send handshake on openConnection', (done) ->
      server.onHandshake = (projId) ->
        assert.equal projId, projectId
        assert.ok @liveSockets[projId]
        done()
      client = new SocketClient()
      client.openConnection projectId, newSocket()

    it 'should trigger callback on message', (done) ->
      client = new SocketClient()
      client.openConnection projectId, newSocket()
      message = messageMaker.addFilesMessage [{
        path: 'some/path'
        isDir: false
      }]
      client.send message, (err, msg) ->
        assert.equal err, null
        assert.ok msg
        assert.equal msg.replyTo, message.id
        console.log "Calling done() in callback"
        done()
      

  describe 'sending messages to client', ->
    projectId = uuid.v4()
    fileId = uuid.v4()
    server = null
    before (done) ->
      server = newServer()
      console.log "**Starting SocketServer-SocketClient"
      controller = { route: (msg, callback) ->
        #console.log "Routing message (has callback: #{callback?}):", msg.id
        #callback? null, null
      }
      server.controller = controller
      server.onHandshake = (projId) ->
        console.log "Got handshake for #{projId}"
        done()
      client = new SocketClient()
      client.onMessage = (msg) ->
        console.log "Calling client.onMessage callback."
        if msg.action == messageAction.REQUEST_FILE
          replyMsg = messageMaker.message {
            action : msg.action
            replyTo : msg.id
          }
          @send replyMsg
      client.openConnection projectId, newSocket()

    after ->
      server.destroy()
      console.log "**Finished SocketServer-SocketClient"
    afterEach ->
      server.onHandshake = null

    it 'should trigger tell callback fweep', (done) ->
      message = messageMaker.requestFileMessage(fileId)
      server.tell projectId, message, (err, responseMsg) ->
        console.log "Calling server.tell callback."
        assert.equal err, null
        assert.ok responseMsg
        assert.equal responseMsg.replyTo, message.id
        done()

