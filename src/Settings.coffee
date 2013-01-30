#TODO: Change Host to Hostname
#Clarify httpHost name (azkaban)

Settings = {
  httpHost: process.env["MADEYE_HTTP_HOST"],
  httpPort: parseInt(process.env["MADEYE_HTTP_PORT"]),
  mongoHost: process.env["MADEYE_MONGO_HOST"],
  mongoPort: parseInt(process.env["MADEYE_MONGO_PORT"]),
  apogeeHost: process.env["MADEYE_APOGEE_HOST"],
  apogeePort: parseInt(process.env["MADEYE_APOGEE_PORT"]),
  bolideHost: process.env["MADEYE_BOLIDE_HOST"],
  bolidePort: process.env["MADEYE_BOLIDE_PORT"],
  kissMetricsId: process.env["MADEYE_KISS_METRICS_ID"],
  googleAnalyticsId: process.env["MADEYE_GOOGLE_ANALYTICS_ID"],
  logglyAzkabanKey: process.env["MADEYE_LOGGLY_AZKABAN_KEY"]
}

exports.Settings = Settings
