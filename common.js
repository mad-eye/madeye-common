require('coffee-script')
exports.Settings = require('./src/Settings').Settings

//Testing
exports.MockSocket = require('./tests/mock/MockIoSocket').MockSocket
exports.MockResponse = require('./tests/mock/mockResponse')

//Errors
exports.errors = require('./src/errors')

//Tools
exports.crc32 = require('./src/crc32').crc32
exports.normalizePath = require("./src/fileUtils").normalizePath
exports.findLineEndingType = require("./src/fileUtils").findLineEndingType
exports.cleanupLineEndings = require("./src/fileUtils").cleanupLineEndings
exports.cors = require('./src/cors')
exports.standardizePath = require("./src/fileUtils").cleanupLineEndings
exports.localizePath = require("./src/fileUtils").localizePath
exports.findParentPath = require("./src/fileUtils").findParentPath
