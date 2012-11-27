#TODO: Change Host to Hostname
#Rename madeye_http to madeye_azkaban
#Addd bolide

Settings = {
  bcHost: process.env["MADEYE_BC_HOST"],
  bcPort: parseInt(process.env["MADEYE_BC_PORT"]),
  httpHost: process.env["MADEYE_HTTP_HOST"],
  httpPort: parseInt(process.env["MADEYE_HTTP_PORT"]),
  mongoHost: process.env["MADEYE_MONGO_HOST"],
  mongoPort: parseInt(process.env["MADEYE_MONGO_PORT"]),
  apogeeHost: process.env["MADEYE_APOGEE_HOST"],
  apogeePort: parseInt(process.env["MADEYE_APOGEE_PORT"])
}

exports.Settings = Settings
