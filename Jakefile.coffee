sys = require "sys"
exec = require('child_process').exec;

run = (task, command, callback) ->
  exec command, (error, stdout, stderr) ->
    console.log "#{task} OUTPUT ", stdout if stdout
    console.log "#{task} ERROR: ", stderr if stderr
    callback?()

desc 'compile all the coffeescript'
task 'compile', {async: true}, (params)->
  run "compile", """coffee --output dist --compile .""", complete

desc "remove all compiled js"
task "clean", {async: true}, (params)->
  run "clean", "rm -rf dist", ->
    console.log "now we're talking"

desc "run the test suite"
task "test", ["compile"], (params)->
  run "test", """find dist/tests -name "*Test.js" | xargs mocha"""
