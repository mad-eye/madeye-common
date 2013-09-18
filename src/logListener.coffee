isMeteor = 'undefined' != typeof Meteor

unless isMeteor
  moment = require 'moment'
else
  if Meteor.isServer
    moment = Npm.require 'moment'
  else #isClient
    moment = (date) -> moment
    moment.format = (format) -> ""


levelnums =
  error: 0
  warn: 1
  info: 2
  debug: 3
  trace: 4

if Meteor?.isClient
  BROWSER = true

  colors =
    error: (x) -> x
    warn: (x) -> x
    info: (x) -> x
    debug: (x) -> x
    trace: (x) -> x
else
  if isMeteor #isServer
    clc = Npm.require 'cli-color'
  else
    clc = require 'cli-color'

  colors =
    error: clc.red.bold
    warn: clc.yellow
    info: clc.bold
    debug: clc.blue
    trace: clc.blackBright

class LogListener
  constructor: (options) ->
    options ?= {}
    @name = options.name ? 'root'
    @logLevel = options.logLevel ? 'info'
    @logLevelnum = levelnums[@logLevel]
    @onError = options.onError

  _printlog: (data) ->
    timestr = moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss.SSS")
    data.name ?= @name
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

    if levelnums[data.level] <= levelnums['warn']
      console.error prefix, message
    else
      console.log prefix, message


  #take single message arg, that is an array.
  _log: (level, messages) ->
    return unless levelnums[level] <= @logLevelnum
    data =
      timestamp: new Date
      level: level
      message: messages
    @_printlog data
    if level == 'error'
      @onError messages

  #take multiple args
  log: (level, messages...) -> @_log level, messages

  trace: (messages...) -> @_log 'trace', messages
  debug: (messages...) -> @_log 'debug', messages
  info: (messages...) -> @_log 'info', messages
  warn: (messages...) -> @_log 'warn', messages
  error: (messages...) -> @_log 'error', messages

  listen: (emitter, name, level) ->
    level ?= @logLevel
    levelnum = levelnums[level]

    emitter.on 'error', (err) =>
      @_printlog level:'error', name:name, message:err

    ['warn', 'info', 'debug', 'trace'].forEach (l) =>
      return if levelnums[l] > levelnum
      emitter.on l, (msgs...) =>
        @_printlog timestamp: new Date, level:l, name:name, message:msgs

if typeof exports == "undefined"
  MadEye.LogListener = LogListener
else
  module.exports = LogListener
