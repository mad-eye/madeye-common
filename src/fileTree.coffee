class FileTree
  #TODO take a root arg as well so we can show relative paths
  constructor: (rawFiles=[], @rootDir="")->
    @files = []
    @setFiles rawFiles

  #TODO: Rename this addFiles
  setFiles: (rawFiles)-> #straight outta mongo, pull files out sorted..?
    rawFiles.forEach (rawFile) =>
      @addFile rawFile, false #don't sort
    @sort()

  addFile: (rawFile, sort=false) ->
    @files.push(new File rawFile, @rootDir)

  sort: ->
    @files.sort File.compare

  #TODO back this by map
  findByPath: (path)->
    for file in @files
      if file.path == path
        return file
    null

  findById: (id)->
    for file in @files
      if file._id == id
        return file
    null

class File
  constructor: (rawFile, rootDir="")-> #straight outta mongo
    @_id = rawFile._id
    @isDir = rawFile.isDir
    @path = trimPath rawFile.path, rootDir

  #TODO see if its easy to make this syntax nicer
  #something like this maybe?
  #  @getter "filename", ->
  #    @path.split("/").pop()
  @.prototype.__defineGetter__ "filename", ->
    stripSlash(@path).split("/").pop()

  @.prototype.__defineGetter__ "depth", ->
    stripSlash(@path).split("/").length - 2 #don't count directory itself or leading /

  [F1_FIRST, F2_FIRST] = [-1,1]
  @compare: (f1, f2) ->
    #we want / to come before everything so a folder's contents come before anything else
    #" " is the first printable ascii character, ! is the second
    #turn all slashes into spaces, and all spaces into !
    [path1, path2] = [f1.path.replace(/\ /g, "!").replace(/\//g, " "),
      f2.path.replace(/\ /g, "!").replace(/\//g, " ")]
    if path1.toLowerCase() < path2.toLowerCase() then F1_FIRST else F2_FIRST

trimPath = (path, rootDir) ->
  if rootDir && path.indexOf(rootDir) == 0
    path = path.substring rootDir.length
  path

stripSlash = (path) ->
  if path.charAt(0) == '/'
    path = path.substring(1)
  if path.charAt(path.length-1) == '/'
    path = path.substring(0, path.length-1)
  path

exports.FileTree = FileTree
exports.File = File
