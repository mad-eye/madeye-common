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
  # Network issues
  CONNECTION_CLOSED : 'CONNECTION_CLOSED'
  DATABASE_ERROR : 'DATABASE_ERROR'
  NETWORK_ERROR : 'NETWORK_ERROR'

errorMessage =
  MISSING_PARAM : 'Required parameter is missing.'
  INVALID_PARAM : 'Parameter is invalid.'
  NO_FILE : 'File not found'
  IS_DIR : 'Illegal operation on a directory.'
  UNKNOWN_ACTION : 'The action is unknown'
  MISSING_OBJECT : 'The object request was missing.'
  # Network issues
  CONNECTION_CLOSED : 'The connection is closed.'
  DATABASE_ERROR : 'There was an error with the database.'
  NETWORK_ERROR : 'There was an error with the connection.'

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
