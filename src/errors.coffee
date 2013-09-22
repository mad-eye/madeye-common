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
# class: An enum-like machine-readable identifier
# reason: A short, human-readable description of the error
# madeye: true -- Denotes this as an error we've processed and can understand.
# details: A longer human-readable description.
#
# Additional parameters can be passed in via the options field of errors.new()
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
      value = options.parameterValue?.toString().substr 0, 100
      "Parameter #{options.parameter} has an invalid value: #{options.parameterValue}"
    #parameter: PARAMETER_NAME
    #parameterValue: PARAMETER_VALUE

  FileNotFound :
    code: 404
    reason:'FileNotFound'
    message: (options) ->
      name = options.filePath ? options.fileId
      "The file #{name} was not found."
    #fileId:
    #filePath:

  VersionOutOfDate :
    code: 403
    reason: 'VersionOutOfDate'
    message: (options) -> "Your version #{options.version} of MadEye is out of date.  Please run 'sudo npm update -g madeye' to get the latest."
    #version:

###

  IS_DIR : 'IS_DIR'
  UNKNOWN_ACTION : 'UNKNOWN_ACTION'
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
  IS_DIR : 'Illegal operation on a directory.'
  UNKNOWN_ACTION : 'The action is unknown'
  MISSING_OBJECT : 'The object request was missing.'
  OUT_OF_DATE : "Your version of MadEye is out of date.  Please run 'sudo npm update -g madeye' to get the latest."
  PERMISSION_DENIED : "You don't have the right permissions for: "
  #When we are trying to initialize a sharejs file but it already has been
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

###

errors =
  new : (type, options={}) ->
    err = errorTypes[type]
    unless err
      throw new Error "Unrecognized error type '#{type}'"
    err.details = err.message(options)
    if isMeteor
      err = new Meteor.Error err.code, err.reason, err.details
    else
      delete err.message

    return err

if typeof exports == "undefined"
  MadEye.Errors = errors
else
  module.exports = errors
