require('coffee-script')
exports.Settings = require('./Settings').Settings
exports.ChannelMessage = require('./messages/ChannelMessage').ChannelMessage
exports.SocketServer = require('./messages/SocketServer').SocketServer
exports.SocketClient = require('./messages/SocketClient').SocketClient
exports.MockSocket = require('./mock/MockSocket').MockSocket
