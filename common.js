require('coffee-script')
exports.Settings = require('./src/Settings').Settings
exports.SocketServer = require('./src/messages/SocketServer').SocketServer
exports.SocketClient = require('./src/messages/SocketClient').SocketClient
exports.messageMaker = require('./src/messages/ChannelMessage').messageMaker
exports.messageAction = require('./src/messages/ChannelMessage').messageAction
exports.MockSocket = require('./tests/mock/MockSocket').MockSocket
exports.FileTree = require('./src/FileTree').FileTree
exports.File = require('./src/FileTree').File
exports.MockSocket = require('./tests/mock/MockSocket').MockSocket
