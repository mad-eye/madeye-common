# An error consists of:
# type: errorType -- an enum-like fixed string
# message: errorMessage -- a human-readable explanation
#
errorType =
  MISSING_PARAM : 'MISSING_PARAM'
  NO_FILE : 'NO_FILE'
  IS_DIR : 'IS_DIR'
  # Network issues
  CONNECTION_CLOSED : 'CONNECTION_CLOSED'

errorMessage =
  MISSING_PARAM : 'Required parameter is missing.'
  NO_FILE : 'File not found'
  IS_DIR : 'Illegal operation on a directory.'
  # Network issues
  CONNECTION_CLOSED : 'The connection is closed.'

errors =
  new : (type) ->
    err = new Error(errorMessage[type])
    err.type = errorType[type]
    return err

exports.errors = errors
exports.errorType = errorType
exports.errorMessage = errorMessage
