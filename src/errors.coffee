isMeteor = 'undefined' != typeof Meteor

###
# CAVEAT CODER: This file is being updated as-needed.  If you upgrade to this
# version of madeye-common, make sure you have updated the error calls.
#
# The structure of these errors is based on Meteor.Error, since we have
# to use that anyway.  To define an error, make a message fn [ (options) ->]
# that will generate the details field.
#
# An error consists of:
# code: An HTTP-like error code.
# reason: A short, human-readable description of the error
# madeye: true -- Denotes this as an error we've processed and can understand.
#   (only on non-Meteor.Errors)
# details: A longer human-readable description.
#
# This returns a Meteor.Error if in meteor, else a JSON object.
####

errorTypes =
  MissingParameter :
    code: 400
    reason: 'MissingParameter'
    message: (options) -> "Required parameter #{options.parameter} is missing."
    #parameter: PARAMETER_NAME

  InvalidParameter :
    code: 400
    reason: 'InvalidParameter'
    message: (options) ->
      value = options.parameterValue?.toString().substr 0, 50
      "Parameter #{options.parameter} has an invalid value: #{options.parameterValue}"
    #parameter: PARAMETER_NAME
    #parameterValue: PARAMETER_VALUE

  FileNotFound :
    code: 404
    reason:'FileNotFound'
    message: (options) ->
      name = options.path ? options.fileId
      "The file #{name} was not found."
    #fileId:
    #path:

  VersionOutOfDate :
    code: 403
    reason: 'VersionOutOfDate'
    message: (options) -> "Your version #{options.version} of MadEye is out of date.  Please run 'sudo npm update -g madeye' to get the latest."
    #version:

  IsDirectory :
    code: 403
    reason: 'IsDirectory'
    message: (options) -> "Illegal operation on a directory."

  PermissionDenied :
    code: 403
    reason: 'PermissionDenied'
    message: (options) -> "You are not allowed to access #{path}"
    #path: filePath

  ProjectClosed :
    code: 403
    reason: 'ProjectClosed'
    message: "The project is closed; the operation cannot be completed."

  NetworkError :
    code: 504
    message: "There seem to be issues with the network.  Please try again later."
###

  MISSING_OBJECT : 'MISSING_OBJECT'
  PERMISSION_DENIED : 'PERMISSION_DENIED'
  INITIALIZED_FILE_NOT_EMPTY : 'INITIALIZED_FILE_NOT_EMPTY' 
  # Network issues
  CONNECTION_CLOSED : 'CONNECTION_CLOSED'
  DATABASE_ERROR : 'DATABASE_ERROR'
  SHAREJS_ERROR : 'SHAREJS_ERROR'
  NETWORK_ERROR : 'NETWORK_ERROR'
  SOCKET_ERROR : 'SOCKET_ERROR'


errorMessage =
  MISSING_OBJECT : 'The object request was missing.'
  #When we are trying to initialize a sharejs file but it already has been
  INITIALIZED_FILE_NOT_EMPTY : "The file has already been initialized.  Using existing version."
  # Network issues
  CONNECTION_CLOSED : 'The connection is closed.'
  DATABASE_ERROR : 'There was an error with the database.'
  SHAREJS_ERROR : 'We had trouble syncing the editor.  Please reload the page.'
  NETWORK_ERROR : 'There was an error with the connection.'
  SOCKET_ERROR : 'There was an error with the connection.'

###

class MadEyeError
  constructor: (type, options) ->
    errType = errorTypes[type]
    unless errType
      throw new Error "Unrecognized error type '#{type}'"
    if 'string' == typeof errType.message
      details = errType.message
    else #it's a fn
      details = errType.message(options)
    if isMeteor
      err = new Meteor.Error errType.code, errType.reason, details
    else
      err =
        code: errType.code
        reason: errType.reason
        details:details
        madeye: true

    return err

errors =
  new : (type, options={}) ->
    #Instantiate new error, don't modify our base types.
    new MadEyeError type, options

if typeof exports == "undefined"
  if 'undefined' == typeof MadEye and 'undefined' != typeof share
      MadEye = share.MadEye
  MadEye.Errors = errors
else
  module.exports = errors
