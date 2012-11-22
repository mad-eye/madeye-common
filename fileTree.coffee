_ = require "underscore" unless Meteor?
util = require "util"

class FileTree
  constructor: (rawFiles)-> #straight outta mongo
    @files = _.map rawFiles, (rawFile) ->
      new File rawFile

  sort: ->
    for file in @files
      @files.sort File.compare

class File
  constructor: (rawFile)-> #straight outta mongo
    @id = rawFile.id
    @isDir = rawFile.isDir
    @path = rawFile.path

#TODO support this syntax
#  @getter "filename", ->
#    @path.split("/").pop()

  @compare: (f1, f2) ->
    [F1_FIRST, F2_FIRST] = [-1,1]
    if f1.path.toLowerCase() < f2.path.toLowerCase() then F1_FIRST else F2_FIRST

exports.FileTree = FileTree
exports.File = File
