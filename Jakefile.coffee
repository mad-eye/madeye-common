util = require "util"
spawn = require('child_process').spawn;
exec = require('child_process').exec;

run = (task, command, args, callback) ->
  #console.log "running command #{command} #{args.join(' ')}"
  process = spawn command, args
  process.stdout.on "data", (data)->
    util.print data
  process.stderr.on "data", (data)->
    util.print data
  process.on "exit", (code)->
    console.log "exited with status #{code}" unless code == 0
    callback?()

compiledTests = (callback)->
  exec """find dist/tests -name "*Test.js" """, (error, stdout, stderr)->
    tests = stdout.split "\n"
    tests.pop()
    callback tests

#TODO abort if compilation fails
desc 'compile all the coffeescript'
task 'compile', {async: true}, (params)->
  run "compile", "coffee", ["--output", "dist", "--compile", "src"], ->
    run "compile", "coffee", ["--output", "dist/tests", "--compile", "tests"], complete

desc "watch for coffeescript changes and compile as necessary"
task 'watch', {async: true}, (params)->
  run "watch", "coffee", ["--watch", "--output", "dist", "--compile", "src"]
  run "watch", "coffee", ["--watch", "--output", "dist/tests", "--compile", "tests"]

desc "remove all compiled js"
task "clean", {async: true}, (params)->
  run "clean", "rm", ["-rf", "dist"], complete

desc "run the test suite"
task "test", ["compile"], {async: true}, (params)->
  compiledTests (tests)->
    run "test", "mocha", tests
