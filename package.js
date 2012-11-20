Package.describe({
  summary: "common files shared by madeye projects"
});

Package.on_use(function (api, where) {
  api.add_files('test.js', 'client');
});
