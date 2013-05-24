Settings = {
  apogeePort: process.env["MADEYE_APOGEE_PORT"],
  apogeeHost: process.env["MADEYE_APOGEE_HOST"],
  apogeeDDPHost: process.env["MADEYE_APOGEE_DDP_HOST"],
  apogeeUrl: process.env["MADEYE_APOGEE_URL"],
  azkabanPort: process.env["MADEYE_AZKABAN_PORT"],
  azkabanHost: process.env["MADEYE_AZKABAN_HOST"],
  azkabanUrl: process.env["MADEYE_AZKABAN_URL"],
  bolidePort: process.env["MADEYE_BOLIDE_PORT"],
  bolideUrl: process.env["MADEYE_BOLIDE_URL"],
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
}

if typeof exports == "undefined"
  MadEye.Settings = Settings
else
  exports.Settings = Settings
