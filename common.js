require('coffee-script')
exports.Settings = require('./src/Settings').Settings
exports.FileTree = require('./src/fileTree').FileTree
exports.File = require('./src/fileTree').File
//exports.MockSocket = require('./tests/mock/MockSocket').MockSocket
exports.MockSocket = require('./tests/mock/MockIoSocket').MockSocket

//Messages
exports.messageMaker = require('./src/messages').messageMaker
exports.messageAction = require('./src/messages').messageAction

//Errors
exports.errors = require('./src/errors').errors
exports.errorType = require('./src/errors').errorType

//Tools
exports.crc32 = require('./src/crc32')

