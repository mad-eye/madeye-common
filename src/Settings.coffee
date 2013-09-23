Settings = {
  apogeePort: process.env["MADEYE_APOGEE_PORT"]
  apogeeUrl: process.env["MADEYE_APOGEE_URL"]
  azkabanPort: process.env["MADEYE_AZKABAN_PORT"]
  azkabanUrl: process.env["MADEYE_AZKABAN_URL"]
  bolidePort: process.env["MADEYE_BOLIDE_PORT"]
  bolideUrl: process.env["MADEYE_BOLIDE_URL"]
  ddpHost: process.env["MADEYE_DDP_HOST"]
  ddpPort: process.env["MADEYE_DDP_PORT"]
  mongoPort: process.env["MADEYE_MONGO_PORT"]
  mongoUrl: process.env["MADEYE_MONGO_URL"]
  googleAnalyticsId: process.env["MADEYE_GOOGLE_ANALYTICS_ID"]
  hangoutPrefix: process.env['MADEYE_HANGOUT_PREFIX']
  hangoutAppId: process.env['MADEYE_HANGOUT_APP_ID']
  userStaticFiles: process.env['MADEYE_USER_STATIC_FILES']
  shareHost: process.env.MADEYE_SHARE_HOST
}

if typeof exports == "undefined"
  MadEye.Settings = Settings
else
  exports.Settings = Settings
