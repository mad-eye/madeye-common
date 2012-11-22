FileTree = require("../filetree").FileTree
File = require("../filetree").File
assert = require "assert"

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

describe "FileTree", ->
  describe "sort", ->
    it "sorts", ->
      tree = new FileTree [{path: "/readme"}, {path: "/azkaban"}, {path: "/Hogwarts"}]
      tree.sort()
      assert.equal tree.files[0].path, "/azkaban"
      assert.equal tree.files[1].path, "/Hogwarts"
      assert.equal tree.files[2].path, "/readme"
