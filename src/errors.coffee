# An error consists of:
# type: errorType -- an enum-like fixed string
# message: errorMessage -- a human-readable explanation
#
errorType =
  MISSING_PARAM : 'MISSING_PARAM'
  INVALID_PARAM : 'INVALID_PARAM'
  NO_FILE : 'NO_FILE'
  IS_DIR : 'IS_DIR'
  # Network issues
  CONNECTION_CLOSED : 'CONNECTION_CLOSED'
  DATABASE_ERROR : 'DATABASE_ERROR'

errorMessage =
  MISSING_PARAM : 'Required parameter is missing.'
  INVALID_PARAM : 'Parameter is invalid.'
  NO_FILE : 'File not found'
  IS_DIR : 'Illegal operation on a directory.'
  # Network issues
  CONNECTION_CLOSED : 'The connection is closed.'
  DATABASE_ERROR : 'There was an error with the databse.'

errors =
  new : (type, @cause) ->
    err = new Error(errorMessage[type])
    err.type = errorType[type]
    return err

exports.errors = errors
exports.errorType = errorType
exports.errorMessage = errorMessage
