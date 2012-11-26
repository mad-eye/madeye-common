_ = require 'underscore'
assert = require 'assert'
uuid = require 'node-uuid'
connect = require 'connect'
browserChannel = require('browserchannel').server
{BCSocket} = require 'browserchannel'
{SocketClient} = require '../../messages/SocketClient'
{SocketServer} = require '../../messages/SocketServer'
{ChannelMessage, messageAction, messageMaker} = require '../../messages/ChannelMessage'
{Settings} = require '../../Settings'

## Tests

#hooks:
#  onmessage : (msg) -> ...
#  onopen : -> ...
makeSocket = (hooks) ->
  socket = new BCSocket "http://localhost:#{Settings.bcPort}/channel"
  socket.onerror = (msg, errCode) ->
    console.error "Error on socket:", msg, errCode
    throw new Error msg
  _.extend(socket, hooks)
  return socket

#XXX: Find way to destroy server after (in-between?) tests.
describe 'SocketServer-integration:', ->
  server = client = controller = null
  projectId = uuid.v4()
  before ->
    controller = { route: (msg, callback) ->
      console.log "Routing message (has callback: #{callback?}):", msg.id
      replyMessage = messageMaker.message
        action: 'test'
        replyTo: msg.id
        shouldConfirm: false
      callback? null, replyMessage
    }
    server = new SocketServer controller
    server.listen Settings.bcPort
  after ->
    server.destroy()
  describe 'Basic Server', ->
    it 'should allow a socket to connect', (done) ->
      makeSocket
        onopen: ->
          message = messageMaker.message
            action: 'test'
            shouldConfirm: false
          console.log "Client sending message", message
          @send message
        onmessage: (msg) ->
          console.log "Client receiving message", msg.id
          assert.ok msg
          done()



  describe 'handshake message', ->
    socket = message = null
    before ->
      socket = new BCSocket "http://localhost:#{Settings.bcPort}/channel"
      socket.onopen = ->
    it 'should confirm handshake and store socket', (done) ->
      makeSocket
        onopen: ->
          message = messageMaker.handshakeMessage()
          message.projectId = projectId
          console.log "Client sending message", message
          @send message
        onmessage : (msg) ->
          console.log 'Client got message', msg.id
          assert.equal msg.action, messageAction.CONFIRM
          assert.equal msg.receivedId, message.id
          assert.ok server.liveSockets[projectId]
          done()





describe 'SocketClient-SocketServer', ->


  
  #describe 'startup', ->
  #  it 'should have received handshake', ->
  #    #client = new SocketClient()
  #    #client.openConnection projectId
  #    assert.ok server.liveSockets[projectId]

#  describe 'sending client to server', ->
#    before ->
#      client = new SocketClient()
#      client.openConnection projectId
      
#    it 'should be received by server', (done) ->
#      message = messageMaker.addFilesMessage [{
#        path: 'some/path'
#        isDir: false
#      }]
#      client.send message, (err, msg) ->
#        assert.equal err, null
#        assert.ok msg
#        done()
      


