Package.describe({
  summary: "common files shared by madeye projects"
});

Package.on_use(function (api, where) {

//is this necessary, found in meteor packages
//where = where || ["client", "server"];
//but absent in atmosphere packages 

  api.use("underscore", "client");
  api.add_files(["preMeteor.js"], ["client", "server"]);
  api.add_files(["dist/fileTree.js"], "client");
  api.add_files(["dist/Settings.js"], "server");
  api.add_files(["postMeteor.js"], ["client", "server"]);
});
