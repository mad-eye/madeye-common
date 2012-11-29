FileTree = require("../src/fileTree").FileTree
File = require("../src/fileTree").File
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

    #tricky because . comes before /
    it "sorts /config/stuff ahead of config.ru", ->
      stuff = new File {path: "/config/stuff"}
      config = new File {path: "/config.ru"}
      assert.equal IN_ORDER, File.compare(stuff, config)

    it "sorts /config/stuff ahead of /config archive", ->
      stuff = new File {path: "/config/stuff"}
      config = new File {path: "/config archive"}
      assert.equal IN_ORDER, File.compare(stuff, config)

describe "FileTree", ->
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
