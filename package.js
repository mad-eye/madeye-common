Package.describe({
  summary: "common files shared by madeye projects"
});

Package.on_use(function (api, where) {
  api.use("underscore", "client");
  api.add_files(["preMeteor.js", "dist/fileTree.js", "postMeteor.js"], "client");
  api.add_files(["preMeteor.js", "postMeteor.js"], "server");
});
