require('coffee-script')
exports.Settings = require('./src/Settings').Settings
exports.Logger = require('./src/logger')

//Testing
exports.MockSocket = require('./tests/mock/MockIoSocket').MockSocket
exports.MockResponse = require('./tests/mock/mockResponse')

//Messages
exports.messageMaker = require('./src/messages').messageMaker
exports.messageAction = require('./src/messages').messageAction

//Errors
exports.errors = require('./src/errors').errors

//Tools
exports.crc32 = require('./src/crc32').crc32
exports.normalizePath = require("./src/fileUtils").normalizePath
exports.findLineEndingType = require("./src/fileUtils").findLineEndingType
exports.cleanupLineEndings = require("./src/fileUtils").cleanupLineEndings
exports.cors = require('./src/cors')
