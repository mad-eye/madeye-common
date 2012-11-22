sys = require "sys"
exec = require('child_process').exec;

run = (task, command, callback) ->
  #console.log "running command #{command}"
  exec command, (error, stdout, stderr) ->
    console.log "#{task} OUTPUT ", stdout if stdout
    console.log "#{task} ERROR: ", stderr if stderr
    callback?()

#TODO abort if compilation fails
desc 'compile all the coffeescript'
task 'compile', {async: true}, (params)->
  run "compile", """coffee --output dist --compile src""", ->
    run "compile", """coffee --output dist/tests --compile tests""", complete

desc "remove all compiled js"
task "clean", {async: true}, (params)->
  run "clean", "rm -rf dist", complete

desc "run the test suite"
task "test", ["compile"], (params)->
  run "test", """find dist/tests -name "*Test.js" -print0 | xargs -0 mocha"""
