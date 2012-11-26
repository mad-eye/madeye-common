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
    @data = {}
    _.extend this, options

  validate: () ->
    ok = @id? and @timestamp?
    ok = false if (@action? and @error?) or (!@action? and !@error?)
    ok = false if (@action == messageAction.CONFIRM) and !@receivedId?


#Message Actions
messageAction =
  HANDSHAKE : 'handshake'
  CONFIRM : 'confirm'
  REQUEST_FILE : 'requestFile'
  SAVE_FILE : 'saveFile'
  ADD_FILES : 'addFiles'
  REMOVE_FILES : 'removeFiles'

messageMaker =
  message : (options) ->
    message = _.extend {
      id : uuid.v4()
      timestamp : new Date().getTime()
      shouldConfirm : true
      data : {}
    }, options

  #Message constructors
  handshakeMessage: ->
    @message action: messageAction.HANDSHAKE

  confirmationMessage: (message) ->
    @message {
      action : messageAction.CONFIRM
      receivedId : message.id
      shouldConfirm : false
    }

  requestFileMessage : (fileId) ->
    @message {
      action : messageAction.REQUEST_FILE
      fileId : fileId
    }

  errorMessage: (error) ->
    @message {
      error : error
    }

  addFilesMessage: (files) ->
    @message {
      action : messageAction.ADD_FILES
      data :
        files : files
    }

  

exports.ChannelMessage = ChannelMessage
exports.messageAction = messageAction
exports.messageMaker = messageMaker
