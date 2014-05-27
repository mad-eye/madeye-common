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
    message: (options) -> options.message
    #message:

  IsDirectory :
    code: 403
    reason: 'IsDirectory'
    message: (options) -> "Illegal operation on a directory."

  PermissionDenied :
    code: 403
    reason: 'PermissionDenied'
    message: (options) -> "You are not allowed to access #{options.path}"
    #path: filePath

  ProjectClosed :
    code: 403
    reason: 'ProjectClosed'
    message: "The project is closed; the operation cannot be completed."

  NetworkError :
    code: 504
    reason: 'NetworkError'
    message: "There seem to be issues with the network.  Please try again later."

  DatabaseError :
    code: 504
    reason: 'DatabaseError'
    message: 'We had an error with the database.  Please try again later.'


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
        details: details
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
