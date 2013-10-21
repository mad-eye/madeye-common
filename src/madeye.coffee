_MadEye =
  isMeteor: 'undefined' != typeof Meteor
  isBrowser: 'undefined' != typeof window

if typeof MadEye != "undefined"
  for k, v of _MadEye
    MadEye[k] = v
else
  if _MadEye.isMeteor
    @MadEye = share.MadEye = _MadEye
  else if _MadEye.isBrowser
    @MadEye = _MadEye
  else
    module.exports = _MadEye

