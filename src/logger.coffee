if 'undefined' == typeof MadEye
  if 'undefined' != typeof share
    MadEye = share.MadEye
  else
    #Should only happen in node
    MadEye = require './madeye'

if MadEye.isBrowser
  moment = (date) -> moment
  moment.format = (format) -> ""
  EventEmitter = MicroEvent
else #isServer
  if MadEye.isMeteor
    moment = Npm.require 'moment'
    {EventEmitter} = Npm.require 'events'
  else
    moment = require 'moment'
    {EventEmitter} = require 'events'

__levelnums =
  error: 0
  warn: 1
  info: 2
  debug: 3
  trace: 4

if MadEye.isBrowser
  colors =
    error: (x) -> x
    warn: (x) -> x
    info: (x) -> x
    debug: (x) -> x
    trace: (x) -> x
else
  if MadEye.isMeteor
    clc = Npm.require 'cli-color'
  else
    clc = require 'cli-color'

  colors =
    error: clc.red.bold
    warn: clc.yellow
    info: clc.bold
    debug: clc.blue
    trace: clc.blackBright


if MadEye.isMeteor
  defaultLogLevel = Meteor.settings?.public?.logLevel
else
  defaultLogLevel = process.env.MADEYE_LOGLEVEL
__loggerLevel = defaultLogLevel ? 'info'

__onError = null

class Listener
  constructor: (options) ->
    options ?= {}
    if 'string' == typeof options
      options = logLevel: options
    #Default logLevel
    @logLevel = options.logLevel ? __loggerLevel
    #logLevels for specific loggers
    @logLevels = {}
    #remember loggers for changing levels later
    @loggers = {}
    # Need to remember these to detach
    # name: {level: fn}
    @listenFns = {}

  setLevel: (level) ->
    return if __loggerLevel == level
    oldLevel = __loggerLevel
    __loggerLevel = level

    #recalculate how we listen to listeners and loggers
    for name, logger of @loggers
      thisLevel = @logLevels[name]
      if thisLevel
        #No need to recaculate if the loggers level is above or below
        #both oldLevel and the new level
        unless level < thisLevel < oldLevel or oldLevel < thisLevel < level
          continue

      @detach name
      @listen logger, name, thisLevel
    return

  setLevels: (name, level) ->
    oldLevel = @logLevels[name]
    return if level == oldLevel
    logger = @loggers[name]
    @detach name
    @listen logger, name, level

  listen: (logger, name, level=null) ->
    unless logger
      throw Error "An object is required for logging!"
    unless name
      throw Error "Name is required for logging!"
    @loggers[name] = logger
    @logLevels[name] = level if level

    level ?= __loggerLevel
    #TODO: Detach possibly existing logger
    @listenFns[name] = {}

    errorFn = (err) =>
      shouldPrint = __onError err
      #Be explicit about false, to not trigger on undefined/null
      unless shouldPrint == false
        @handleLog timestamp: new Date, level:'error', name:name, message:err
    logger.on 'error', errorFn
    @listenFns[name]['error'] = errorFn

    ['warn', 'info', 'debug', 'trace'].forEach (l) =>
      return if __levelnums[l] > __levelnums[level]
      listenFn = (msgs...) =>
        @handleLog timestamp: new Date, level:l, name:name, message:msgs
      logger.on l, listenFn
      @listenFns[name][l] = listenFn
    return

  detach: (name) ->
    logger = @loggers[name]
    return unless logger
    for level, listenFn of @listenFns[name]
      logger.removeListener level, listenFn
    delete @listenFns[name]
    delete @loggers[name]
    delete @logLevels[name]
    return
  
  handleLog: (data) ->
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
          #FIXME: Handle circular structures
          message += JSON.stringify(msg) + ' '
  
    if __levelnums[data.level] <= __levelnums['warn']
      console.error prefix, message
    else
      console.log prefix, message

listener = new Listener()

class Logger extends EventEmitter
  constructor: (options) ->
    options ?= {}
    if 'string' == typeof options
      options = name: options
    @name = options.name
    listener.listen this, options.name, options.logLevel

  @setLevel: (level) ->
    listener.setLevel level

  @setLevels: (name, level) ->
    listener.setLevels name, level

  @onError: (callback) ->
    __onError = callback

  @listen: (logger, name, level) ->
    listener.listen logger, name, level

  #take single message arg, that is an array.
  _log: (level, messages) ->
    messages.unshift level
    @emit.apply this, messages

  #take multiple args
  log: (level, messages...) -> @_log level, messages

  trace: (messages...) -> @_log 'trace', messages
  debug: (messages...) -> @_log 'debug', messages
  info: (messages...) -> @_log 'info', messages
  warn: (messages...) -> @_log 'warn', messages
  error: (messages...) -> @_log 'error', messages

if typeof exports == "undefined"
  MadEye.Logger = Logger
  MadEye.Logger.listener = listener
else
  module.exports = Logger
