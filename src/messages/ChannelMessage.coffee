uuid = require 'node-uuid'
_ = require 'underscore'

#FIXME: Need to rename this file.

#Message Actions
messageAction =
  HANDSHAKE : 'handshake'
  CONFIRM : 'confirm'
  REPLY : 'reply'
  REQUEST_FILE : 'requestFile'
  SAVE_FILES : 'saveFiles'
  ADD_FILES : 'addFiles'
  REMOVE_FILES : 'removeFiles'

# Messages are of the form:
#   id: uuid (required)
#   error: an error message (eventually a machine-readable handle and a human-readable description)
#   action: handshake, confirm, heartbeat, #general
#           addFiles, removeFiles,    #dementor to azkaban
#           requestFile, saveFiles         #azkaban to dementor
#   projectId: (required for dementor to azkaban)
#   replyTo: uuid of message replied to
#   timestamp: milliseconds from epoch (required)
#   receivedId: received message id (for confirm messages only)
#   data: JSON object payload
#
# Each message must have EITHER an action OR an error, but not both.
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

  replyMessage: (message, data) ->
    @message {
      action : messageAction.REPLY
      replyTo : message.id
      replyAction : message.action
      data : data
    }

  requestFileMessage : (fileId) ->
    @message {
      action : messageAction.REQUEST_FILE
      fileId : fileId
    }

  errorMessage: (error, replyId) ->
    @message {
      action : messageAction.REPLY
      error : error
      shouldConfirm : false
      replyTo : replyId
    }

  addFilesMessage: (files) ->
    @message {
      action : messageAction.ADD_FILES
      data :
        files : files
    }

  removeFilesMessage: (files) ->
    @message {
      action : messageAction.REMOVE_FILES
      data :
        files : files
    }

  saveFilesMessage: (files) ->
    @message {
      action : messageAction.SAVE_FILES
      data :
        files : files
    }

exports.messageAction = messageAction
exports.messageMaker = messageMaker
