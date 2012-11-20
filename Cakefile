exec = require('child_process').exec;

task "compile", "compile all the coffeescript", ->
  child = exec """coffee --output dist --compile .""", (error, stdout, stderr) ->
    console.log "compile OUTPUT ", coffeeFiles if stdout
    console.log 'compile ERROR: ', stderr if stderr

task "clean", "remove all compiled js", ->
  child = exec """rm -rf dist""", (error, stdout, stderr) ->
    console.log "clean OUTPUT ", coffeeFiles if stdout
    console.log 'clean ERROR: ', stderr if stderr