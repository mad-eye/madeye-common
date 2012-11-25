require('coffee-script')
exports.Settings = require('./src/Settings').Settings
exports.ChannelMessage = require('./src/messages/ChannelMessage').ChannelMessage
exports.SocketServer = require('./src/messages/SocketServer').SocketServer
exports.SocketClient = require('./src/messages/SocketClient').SocketClient
exports.MockSocket = require('./tests/mock/MockSocket').MockSocket
