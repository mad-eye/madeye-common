#Normalize a natural filepath for filetree ordering.
normalizePath = (path)->
  path.replace(/\ /g, "!").replace(/\//g, " ").toLowerCase()

if (typeof exports != "undefined")
  exports.normalizePath = normalizePath
else
  MadEye.normalizePath = normalizePath
