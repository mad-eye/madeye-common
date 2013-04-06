FileTree = require("../../src/fileTree").FileTree
File = require("../../src/fileTree").File
assert = require "assert"
_path = require "path"
uuid = require "node-uuid"
_ = require 'underscore'

describe "File", ->
  IN_ORDER = -1

  describe "constructor", ->
    it "sorts /a ahead of /b", ->
      aFile = new File {path: "/a", isDir: false}
      bFile = new File {path: "/b", isDir: false}
      assert.equal IN_ORDER, File.compare(aFile, bFile)

    it "sorts /a ahead of /a/stuff", ->
      aDir = new File {path: "/a", isDir: true}
      aStuff = new File {path: "/a/stuff", isDir: false}
      assert.equal IN_ORDER, File.compare(aDir, aStuff)

    it "sorts /a/donotreadme ahead of /a/README", ->
      donotreadme = new File {path: "/a/donotreadme"}
      readme = new File {path: "/a/README"}
      assert.equal IN_ORDER, File.compare(donotreadme, readme)

    it "sorts /a/DONOTREADME ahead of /a/readme", ->
      donotreadme = new File {path: "/a/DONOTREADME"}
      readme = new File {path: "/a/readme"}
      assert.equal IN_ORDER, File.compare(donotreadme, readme)

    #tricky because . comes before /
    it "sorts /config/stuff ahead of config.ru", ->
      stuff = new File {path: "/config/stuff"}
      config = new File {path: "/config.ru"}
      assert.equal IN_ORDER, File.compare(stuff, config)

    it "sorts /config/stuff ahead of /config archive", ->
      stuff = new File {path: "/config/stuff"}
      config = new File {path: "/config archive"}
      assert.equal IN_ORDER, File.compare(stuff, config)

  describe "parentPath", ->
    fileMap = fileTree = null
    before ->
      fileMap =
        file1 : 'this is file1'
        dir1 :
          file2 : 'this is file2'
          dir2:
            file3 : 'this is file3'
        dir3 : {}
      fileTree = constructFileTree fileMap
    it "should give null for top level files and dirs", ->
      file1 = fileTree.findByPath 'file1'
      dir1 = fileTree.findByPath 'dir1'
      dir3 = fileTree.findByPath 'dir3'
      assert.equal file1.parentPath, null
      assert.equal dir1.parentPath, null
      assert.equal dir3.parentPath, null
    it "should give dir1 for first-level nesting", ->
      file2 = fileTree.findByPath 'dir1/file2'
      dir2 = fileTree.findByPath 'dir1/dir2'
      assert.equal file2.parentPath, 'dir1'
      assert.equal dir2.parentPath, 'dir1'
    it "should give dir1/dir2 for second-level nesting", ->
      file3 = fileTree.findByPath 'dir1/dir2/file3'
      assert.equal file3.parentPath, 'dir1/dir2'

  describe 'filename', ->
    it 'should be foo.txt for a/path/foo.txt', ->
      file = new File path: 'a/path/foo.txt'
      assert.equal file.filename, 'foo.txt'
    it 'should be foo.txt for /a/path/foo.txt', ->
      file = new File path: '/a/path/foo.txt'
      assert.equal file.filename, 'foo.txt'


describe "FileTree", ->

  describe "constructor", ->
    it "accepts a null rawFiles argument", ->
      #Shouldn't throw an error
      tree = new FileTree

  describe "addFiles", ->
    it "accepts a null rawFiles argument", ->
      #Shouldn't throw an error
      tree = new FileTree
      tree.addFiles null

  describe "addFile", ->
    it "accepts a null rawFile argument", ->
      #Shouldn't throw an error
      tree = new FileTree
      tree.addFile null

  describe "sort", ->
    it "sorts", ->
      tree = new FileTree [{path: "/readme"}, {path: "/azkaban"}, {path: "/Hogwarts"}]
      tree.sort()
      assert.equal tree.files[0].path, "/azkaban"
      assert.equal tree.files[1].path, "/Hogwarts"
      assert.equal tree.files[2].path, "/readme"

    it "can find by path", ->
      tree = new FileTree [{path: "/readme"}, {path: "/azkaban"}, {path: "/Hogwarts"}]
      assert.deepEqual tree.findByPath("/readme"), new File({path: "/readme"})

  describe "removeFiles", ->
    tree = null
    before ->
      tree = new FileTree [{path: "/readme"}, {path: "/azkaban"}, {path: "/Hogwarts"}]
      tree.removeFiles ["/readme", "/somethingelse"]

    it "removes paths", ->
      assert.ok !_.any tree.files, (file) ->
        file.path == "/readme"

    it "does not remove other files", ->
      assert.equal tree.files.length, 2


#TODO: This is duplicate of dementor/test/util/fileUtils.  Move that to common.
constructFileTree = (fileMap, root="", fileTree) ->
  fileTree ?= new FileTree(null, root)
  makeRawFile = (path, value) ->
    rawFile = {
      _id : uuid.v4()
      path : path
      isDir : (typeof value != "string")
    }
    return rawFile
  for key, value of fileMap
    fileTree.addFile makeRawFile _path.join(root, key), value
    unless typeof value == "string"
      constructFileTree(value, _path.join(root, key), fileTree)
  return fileTree


