isMeteor = 'undefined' != typeof Meteor

unless isMeteor
  moment = require 'moment'
else
  if Meteor.isServer
    moment = Npm.require 'moment'
  else #isClient
    moment = (date) -> moment
    moment.format = (format) -> ""


__levelnums =
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


__loggerLevel = 'info'
__onError = null

class Logger
  constructor: (options) ->
    options ?= {}
    if 'string' == typeof options
      options = name: options
    @name = options.name
    @logLevel = options.logLevel ? __loggerLevel

  @setLevel: (level) ->
    __loggerLevel = level
    #TODO: reset how we listen to listeners and loggers

  @onError: (callback) ->
    __onError = callback

  @listen: (emitter, name, level=null) ->
    unless emitter
      throw Error "An object is required for logging!"
    unless name
      throw Error "Name is required for logging!"
    level ?= __loggerLevel
    levelnum = __levelnums[level]

    emitter.on 'error', (err) =>
      _printlog level:'error', name:name, message:err
      __onError err

    ['warn', 'info', 'debug', 'trace'].forEach (l) =>
      return if __levelnums[l] > levelnum
      emitter.on l, (msgs...) =>
        _printlog timestamp: new Date, level:l, name:name, message:msgs

  _printlog = (data) ->
    timestr = moment(data.timestamp).format("YYYY-MM-DD HH:mm:ss.SSS")
    color = colors[data.level]
    prefix = "#{timestr} #{color(data.level+": ")} "
    prefix += "[#{data.name}] " if data.name

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
  
    if __levelnums[data.level] <= __levelnums['warn']
      console.error prefix, message
    else
      console.log prefix, message


  #take single message arg, that is an array.
  _log: (level, messages) ->
    return unless __levelnums[level] <= __levelnums[@logLevel]
    data =
      name: @name
      level: level
      message: messages
      timestamp: new Date
    _printlog data
    if level == 'error'
      __onError messages

  #take multiple args
  log: (level, messages...) -> @_log level, messages

  trace: (messages...) -> @_log 'trace', messages
  debug: (messages...) -> @_log 'debug', messages
  info: (messages...) -> @_log 'info', messages
  warn: (messages...) -> @_log 'warn', messages
  error: (messages...) -> @_log 'error', messages

if typeof exports == "undefined"
  MadEye.Logger = Logger
else
  module.exports = Logger
