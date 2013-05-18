_ = require 'underscore'

# An error consists of:
# type: errorType -- an enum-like fixed string
# message: errorMessage -- a human-readable explanation
#
errorType =
  MISSING_PARAM : 'MISSING_PARAM'
  INVALID_PARAM : 'INVALID_PARAM'
  NO_FILE : 'NO_FILE'
  IS_DIR : 'IS_DIR'
  UNKNOWN_ACTION : 'UNKNOWN_ACTION'
  MISSING_OBJECT : 'MISSING_OBJECT'
  OUT_OF_DATE : 'OUT_OF_DATE'
  PERMISSION_DENIED : 'PERMISSION_DENIED'
  INITIALIZED_FILE_NOT_EMPTY : 'INITIALIZED_FILE_NOT_EMPTY' #When we are trying to initialize a sharejs file but it already has been
  # Network issues
  CONNECTION_CLOSED : 'CONNECTION_CLOSED'
  DATABASE_ERROR : 'DATABASE_ERROR'
  SHAREJS_ERROR : 'SHAREJS_ERROR'
  NETWORK_ERROR : 'NETWORK_ERROR'
  SOCKET_ERROR : 'SOCKET_ERROR'

  #Interview errors
  UNKNOWN_LANGUAGE : 'UNKNOWN_LANGUAGE'

errorMessage =
  MISSING_PARAM : 'Required parameter is missing.'
  INVALID_PARAM : 'Parameter is invalid.'
  NO_FILE : 'File not found'
  IS_DIR : 'Illegal operation on a directory.'
  UNKNOWN_ACTION : 'The action is unknown'
  MISSING_OBJECT : 'The object request was missing.'
  OUT_OF_DATE : "Your version of MadEye is out of date.  Please run 'sudo npm update -g madeye' to get the latest."
  PERMISSION_DENIED : "You don't have the right permissions for: "
  INITIALIZED_FILE_NOT_EMPTY : "The file has already been initialized.  Using existing version."
  # Network issues
  CONNECTION_CLOSED : 'The connection is closed.'
  DATABASE_ERROR : 'There was an error with the database.'
  SHAREJS_ERROR : 'We had trouble syncing the editor.  Please reload the page.'
  NETWORK_ERROR : 'There was an error with the connection.'
  SOCKET_ERROR : 'There was an error with the connection.'

  #Interview errors
  UNKNOWN_LANGUAGE : 'Currently we only support javascript, coffeescript, ruby, and python.'

  #Interview errors
  UNKNOWN_LANGUAGE : 'Currently we only support javascript, coffeescript, ruby, and python.'

errors =
  new : (type, options={}) ->
    err =
      type: errorType[type]
      message: errorMessage[type]
      madeye: true
    _.extend err, options
    return err

exports.errors = errors
exports.errorType = errorType
exports.errorMessage = errorMessage
