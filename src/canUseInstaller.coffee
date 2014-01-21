canUseInstaller = ({platform, arch, release}) ->
  #unknown platform, return undefined
  return undefined unless platform and arch
  if platform == 'darwin' and arch == 'x64'
    return true
  else if platform == 'linux' and (arch == 'x64' or arch == 'ia32')
    return true
  else #unsupported platform
    return false

if (typeof exports != "undefined")
  exports.canUseInstaller = canUseInstaller
else
  MadEye.canUseInstaller = canUseInstaller
