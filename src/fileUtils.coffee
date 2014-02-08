_path = require 'path'

exports.cleanupLineEndings = (contents) ->
  return contents unless (/\r/.test contents)
  lineBreakRegex = /(\r\n|\r|\n)/gm
  hasDos = /\r\n/.test contents
  hasUnix = /[^\r]\n/.test contents
  hasOldMac = /\r(?!\n)/.test contents
  if hasUnix
    contents.replace lineBreakRegex, '\n'
  else if hasDos and hasOldMac
    contents.replace lineBreakRegex, '\r\n'
  else
    contents

exports.findLineEndingType = (contents) ->
  hasDos = /\r\n/.test contents
  hasUnix = /[^\r]\n/.test contents
  hasOldMac = /\r(?!\n)/.test contents
  return 'DOS' if hasDos
  return 'Unix' if hasUnix
  return 'Mac' if hasOldMac

exports.standardizePath = standardizePath = (path) ->
  return unless path?
  return path if _path.sep == '/'
  return path.split(_path.sep).join('/')

exports.localizePath = localizePath = (path) ->
  return unless path?
  return path if _path.sep == '/'
  return path.split('/').join(_path.sep)

exports.findParentPath = (path) ->
  #Need to localize path seps for _path.dirname to work
  standardizePath _path.dirname(localizePath(path))
