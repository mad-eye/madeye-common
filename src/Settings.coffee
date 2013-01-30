#TODO: Change Host to Hostname
#Clarify httpHost name (azkaban)

Settings = {
  apogeeUrl: process.env["MADEYE_APOGEE_URL"],
  azkabanUrl: process.env["MADEYE_AZKABAN_URL"],
  bolideUrl: process.env["MADEYE_BOLIDE_URL"],
  mongoUrl: process.env["MADEYE_MONGO_URL"],
  kissMetricsId: process.env["MADEYE_KISS_METRICS_ID"],
  googleAnalyticsId: process.env["MADEYE_GOOGLE_ANALYTICS_ID"],
  logglyAzkabanKey: process.env["MADEYE_LOGGLY_AZKABAN_KEY"]
}

exports.Settings = Settings
