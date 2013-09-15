exports.normalizePath = (path)->
  path.replace(/\ /g, "!").replace(/\//g, " ").toLowerCase()

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

