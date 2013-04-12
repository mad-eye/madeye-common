exports.normalizePath = (path)->
  path.replace(/\ /g, "!").replace(/\//g, " ").toLowerCase()