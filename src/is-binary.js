// Generated by CoffeeScript 1.6.2
(function() {
  var extensions, exts, isBinaryExt;

  extensions = ['adp', 'au', 'mid', 'mp4a', 'mpga', 'oga', 's3m', 'sil', 'eol', 'dra', 'dts', 'dtshd', 'lvp', 'pya', 'ecelp4800', 'ecelp7470', 'ecelp9600', 'rip', 'weba', 'aac', 'aif', 'caf', 'flac', 'mka', 'm3u', 'wax', 'wma', 'wav', 'xm', 'flac', '3gp', '3g2', 'h261', 'h263', 'h264', 'jpgv', 'jpm', 'mj2', 'mp4', 'mpeg', 'ogv', 'qt', 'uvh', 'uvm', 'uvp', 'uvs', 'dvb', 'fvt', 'mxu', 'pyv', 'uvu', 'viv', 'webm', 'f4v', 'fli', 'flv', 'm4v', 'mkv', 'mng', 'asf', 'vob', 'wm', 'wmv', 'wmx', 'wvx', 'movie', 'smv', 'ts', 'bmp', 'cgm', 'g3', 'gif', 'ief', 'jpg', 'jpeg', 'ktx', 'png', 'btif', 'sgi', 'svg', 'tiff', 'psd', 'uvi', 'sub', 'djvu', 'dwg', 'dxf', 'fbs', 'fpx', 'fst', 'mmr', 'rlc', 'mdi', 'wdp', 'npx', 'wbmp', 'xif', 'webp', '3ds', 'ras', 'cmx', 'fh', 'ico', 'pcx', 'pic', 'pnm', 'pbm', 'pgm', 'ppm', 'rgb', 'tga', 'xbm', 'xpm', 'xwd', 'zip', 'rar', 'tar', 'bz2', 'eot', 'ttf', 'woff'];

  exts = Object.create(null);

  extensions.forEach(function(extension) {
    return exts[extension] = true;
  });

  isBinaryExt = function(extension) {
    if (!extension) return false;
    return !!exts[extension.toLowerCase()];
  };

  if (typeof exports != "undefined")
    exports.isBinaryExt = isBinaryExt
  else
    MadEye.isBinaryExt = isBinaryExt
}).call(this);
