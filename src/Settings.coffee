Settings = {
  apogeePort: process.env["MADEYE_APOGEE_PORT"],
  apogeeUrl: process.env["MADEYE_APOGEE_URL"],
  azkabanPort: process.env["MADEYE_AZKABAN_PORT"],
  azkabanUrl: process.env["MADEYE_AZKABAN_URL"],
  bolidePort: process.env["MADEYE_BOLIDE_PORT"],
  bolideUrl: process.env["MADEYE_BOLIDE_URL"],
  ddpHost: process.env["MADEYE_DDP_HOST"],
  ddpPort: process.env["MADEYE_DDP_PORT"],
  nurmengardPort: process.env["MADEYE_NURMENGARD_PORT"],
  nurmengardUrl: process.env["MADEYE_NURMENGARD_URL"],
  mongoPort: process.env["MADEYE_MONGO_PORT"],
  mongoUrl: process.env["MADEYE_MONGO_URL"],
  kissMetricsId: process.env["MADEYE_KISS_METRICS_ID"],
  googleAnalyticsId: process.env["MADEYE_GOOGLE_ANALYTICS_ID"],
  logglyAzkabanKey: process.env["MADEYE_LOGGLY_AZKABAN_KEY"]
  logglyApogeeKey: process.env["MADEYE_LOGGLY_APOGEE_KEY"]
  logglyDementorKey: process.env["MADEYE_LOGGLY_DEMENTOR_KEY"]
  logglyNurmengardKey: process.env["MADEYE_LOGGLY_NURMENGARD_KEY"]
  hangoutPrefix: process.env['MADEYE_HANGOUT_PREFIX']
  hangoutAppId: process.env['MADEYE_HANGOUT_APP_ID']
  userStaticFiles: process.env['MADEYE_USER_STATIC_FILES']
}

if typeof exports == "undefined"
  MadEye.Settings = Settings
else
  exports.Settings = Settings
