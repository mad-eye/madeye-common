clc = require 'cli-color'
moment = require 'moment'

levelnums =
  error: 0
  warn: 1
  info: 2
  debug: 3
  trace: 4

colors =
  error: clc.red.bold
  warn: clc.yellow
  info: clc.reset
  debug: clc.blue
  trace: clc.blackBright

class LogListener
  constructor: (options) ->
    options ?= {}
    @logLevel = options.logLevel ? 'info'
    @logLevelnum = levelnums[@logLevel]
    @onError = options.onError

  _printlog: (data) ->
    timestr = moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss.SSS")
    data.name ?= 'root'
    color = colors[data.level]
    prefix = "#{timestr} #{color(data.level+": ")} [#{data.name}] "

    if 'string' == typeof data.message
      message = data.message
    else
      #Passing message as an array of args.
      message = ''
      for msg in data.message
        if 'string' == typeof msg
          message += msg + ' '
        else
          message += JSON.stringify(msg) + ' '
      data.message = message

    if levelnums[data.level] <= levelnums['warn']
      console.error prefix, message
    else
      console.log prefix, message


  log: (level, message) ->
    return unless levelnums[level] <= @logLevelnum
    data =
      timestamp: new Date
      level: level
      message: message
    @_printlog data
    if level == 'error'
      @onError message

  listen: (emitter, name, level) ->
    level ?= @logLevel
    levelnum = levelnums[level]

    emitter.on 'error', (err) =>
      @_printlog level:'error', name:name, message:err

    ['warn', 'info', 'debug', 'trace'].forEach (l) =>
      return if levelnums[l] > levelnum
      emitter.on l, (msgs...) =>
        @_printlog timestamp: new Date, level:l, name:name, message:msgs

module.exports = LogListener
