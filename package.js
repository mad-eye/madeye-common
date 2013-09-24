Package.describe({
  summary: "common files shared by madeye projects"
});

Npm.depends({
  semver: '2.1.0', //Used by apogee server
  moment: '2.2.1',
  'cli-color': '0.2.2'

});

Package.on_use(function (api, where) {

  api.use(["coffeescript", 'underscore'], ["client", "server"]);

  api.add_files(["preMeteor.js"], ["client", "server"]);
  api.add_files(["src/logger.coffee", 'src/errors.coffee', "src/crc32.js"], ["client", 'server']);
  api.add_files(["postMeteor.js"], ["client", "server"]);
});
