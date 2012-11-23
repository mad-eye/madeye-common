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
    ok = false if (@action == messageAction.CONFIRM) and !@receivedId?

  toJSON: () ->
    JSON.stringify this


#Message Actions
messageAction =
  HANDSHAKE : 'handshake'
  CONFIRM : 'confirm'
  REQUEST_FILE : 'requestFile'
  SAVE_FILE : 'saveFile'
  ADD_FILES : 'addFiles'
  REMOVE_FILES : 'removeFiles'

messageMaker =
  #Message constructors
  handshakeMessage: (projectId) ->
    return new ChannelMessage messageAction.HANDSHAKE,
      projectId: projectId

  confirmationMessage: (message) ->
    confirmationMessage = new ChannelMessage(messageAction.CONFIRM)
    confirmationMessage.receivedId = message.id
    confirmationMessage.important = false
    return confirmationMessage

  fileRequestMessage : (fileId) ->
    message = new ChannelMessage(messageAction.REQUEST_FILE)
    message.fileId = fileId
    return message

  errorMessage: (error) ->
    message = new ChannelMessage(null)
    message.error = error

exports.ChannelMessage = ChannelMessage
exports.messageAction = messageAction
exports.messageMaker = messageMaker
