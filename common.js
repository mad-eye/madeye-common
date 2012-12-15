require('coffee-script')
exports.Settings = require('./src/Settings').Settings
exports.SocketServer = require('./src/messages/SocketServer').SocketServer
exports.SocketClient = require('./src/messages/SocketClient').SocketClient
exports.messageMaker = require('./src/messages/messages').messageMaker
exports.messageAction = require('./src/messages/messages').messageAction
exports.MockSocket = require('./tests/mock/MockSocket').MockSocket
exports.FileTree = require('./src/fileTree').FileTree
exports.File = require('./src/fileTree').File
exports.MockSocket = require('./tests/mock/MockSocket').MockSocket

//Errors
exports.errors = require('./src/errors').errors
exports.errorType = require('./src/errors').errorType

