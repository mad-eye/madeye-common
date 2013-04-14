Package.describe({
  summary: "common files shared by madeye projects"
});

Package.on_use(function (api, where) {

//is this necessary, found in meteor packages
//where = where || ["client", "server"];
//but absent in atmosphere packages 

  api.use("coffeescript", ["client", "server"]);
  api.use("underscore", ["client", "server"]);
  api.add_files(["preMeteor.js"], ["client", "server"]);
//  api.add_files(["src/fileTree.coffee"], ["client", "server"])
  api.add_files(["src/Settings.coffee"], "server");
  api.add_files(["src/crc32.js"], "client");
  api.add_files(["postMeteor.js"], ["client", "server"]);
});
