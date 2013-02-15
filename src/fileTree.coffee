_ = require("underscore") unless _?

#emulate ES5 getter/setter API using legacy APIs
if Object.prototype.__defineGetter__ && !Object.defineProperty
  Object.defineProperty = (obj,prop,desc) ->
    if ("get" in desc) then obj.__defineGetter__(prop,desc.get)
    if ("set" in desc) then obj.__defineSetter__(prop,desc.set)

class FileTree
  constructor: (rawFiles=[])->
    @setFiles rawFiles

  setFiles: (rawFiles)-> #straight outta mongo, pull files out sorted..?
    @files = []
    @addFiles rawFiles

  addFiles: (rawFiles=[])-> #straight outta mongo, pull files out sorted..?
    rawFiles.forEach (rawFile) =>
      @addFile rawFile, false #don't sort
    @sort()

  addFile: (rawFile, sort=false) ->
    return unless rawFile?
    @files.push(new File rawFile)

  sort: ->
    @files.sort File.compare

  removeFiles: (paths) ->
    @files = _.reject @files, (file) ->
      file.path in paths

  #TODO back this by map
  findByPath: (path)->
    return null unless path?
    for file in @files
      if file.path == path
        return file
    null

  findById: (id)->
    return null unless id?
    for file in @files
      if file._id == id
        return file
    null

class File
  constructor: (rawFile)-> #straight outta mongo
    _.extend @, rawFile

  [F1_FIRST, F2_FIRST] = [-1,1]
  @compare: (f1, f2) ->
    #we want / to come before everything so a folder's contents come before anything else
    #" " is the first printable ascii character, ! is the second
    #turn all slashes into spaces, and all spaces into !
    [path1, path2] = [f1.path.replace(/\ /g, "!").replace(/\//g, " "),
      f2.path.replace(/\ /g, "!").replace(/\//g, " ")]
    if path1.toLowerCase() < path2.toLowerCase() then F1_FIRST else F2_FIRST

  stripSlash : (path) ->
    if path.charAt(0) == '/'
      path = path.substring(1)
    if path.charAt(path.length-1) == '/'
      path = path.substring(0, path.length-1)
    path

Object.defineProperty File.prototype, 'filename',
  get: -> @stripSlash(@path).split('/').pop()

Object.defineProperty File.prototype, 'depth',
  get: -> @stripSlash(@path).split('/').length - 1 #don't count directory itself or leading /

Object.defineProperty File.prototype, 'parentPath',
  get: ->
    rightSlash = @path.lastIndexOf('/')
    if rightSlash > 0
      return @path.substring 0, rightSlash
    else
      return null




exports.FileTree = FileTree
exports.File = File
