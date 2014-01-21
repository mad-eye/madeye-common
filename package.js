Package.describe({
  summary: "common files shared by madeye projects"
});

Package.on_use(function (api, where) {

  api.use(["coffeescript", 'underscore'], ["client", "server"]);

  api.add_files(["preMeteor.js", "src/madeye.coffee"], ["client", "server"]);
  api.add_files(['src/errors.coffee', "src/crc32.js", 'src/canUseInstaller.coffee', 'src/is-binary.js'], ["client", 'server']);
  api.add_files(["postMeteor.js"], ["client", "server"]);

  api.export("MadEye", ["server", "client"]);
});
