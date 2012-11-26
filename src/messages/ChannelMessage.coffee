uuid = require 'node-uuid'
_ = require 'underscore'

# Messages are of the form:
#   id: uuid (required)
#   error: an error message (eventually a machine-readable handle and a human-readable description)
#   action: handshake, confirm, heartbeat, #general
#           addFiles, removeFiles,    #dementor to azkaban
#           requestFile, saveFile         #azkaban to dementor
#   projectId: (required for dementor to azkaban)
#   replyTo: uuid of message replied to
#   timestamp: milliseconds from epoch (required)
#   receivedId: received message id (for confirm messages only)
#   data: JSON object payload
#
# Each message must have EITHER an action OR an error, but not both.
class ChannelMessage
  #Options includes the various top-level attributes to be set.
  constructor: (@action, options) ->
    @id = uuid.v4()
    @replyTo = null
    @projectId = null
    @timestamp = new Date().getTime()
    @important = true
    _.extend this, options

  validate: () ->
    ok = @id? and @timestamp?
    ok = false if (@action? and @error?) or (!@action? and !@error?)
    ok = false if (@action == ChannelMessage.CONFIRM) and !@receivedId?

  #Message constructors
  @confirmationMessage: (message) ->
    confirmationMessage = new ChannelMessage(ChannelMessage.CONFIRM)
    confirmationMessage.receivedId = message.id
    confirmationMessage.important = false
    return confirmationMessage

  @fileRequestMessage : (fileId) ->
    message = new ChannelMessage(ChannelMessage.REQUEST_FILE)
    message.fileId = fileId
    return message

  @errorMessage: (error) ->
    message = new ChannelMessage(null)
    message.error = error

#Message Actions
ChannelMessage.HANDSHAKE = 'handshake'
ChannelMessage.CONFIRM = 'confirm'
ChannelMessage.REQUEST_FILE = 'requestFile'
ChannelMessage.SAVE_FILE = 'saveFile'
ChannelMessage.ADD_FILES = 'addFiles'
ChannelMessage.REMOVE_FILES = 'removeFiles'


exports.ChannelMessage = ChannelMessage
