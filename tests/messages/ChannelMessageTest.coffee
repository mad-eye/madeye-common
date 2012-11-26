assert = require 'assert'
{ChannelMessage, messageAction, messageMaker} = require '../../src/messages/ChannelMessage'

describe 'ChannelMessage', ->
  describe 'confirmationMessage', ->
    origMessage = confMessage = null
    before ->
      origMessage = new ChannelMessage(null)
      confMessage = messageMaker.confirmationMessage origMessage
    it 'should not be null', ->
      assert.ok confMessage
    it 'should have action "confirm"', ->
      assert.equal confMessage.action, 'confirm'
    it 'should have receivedId equal to send messages id', ->
      assert.equal confMessage.receivedId, origMessage.id

