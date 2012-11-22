Package.describe({
  summary: "common files shared by madeye projects"
});

Package.on_use(function (api, where) {
  api.add_files("preMeteor.js", "client");
  api.add_files('dist/fileTree.js', 'client')
  api.add_files("postMeteor.js", "client");

  api.add_files("preMeteor.js", "server");
  api.add_files("postMeteor.js", "server");
});
