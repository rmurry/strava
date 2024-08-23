library(dplyr)
library(httr)
library(jsonlite)
library(lubridate)
library(glue)

beg_of_year <- as.POSIXct('2024-01-01',format = '%Y-%m-%d %HH:%MM:%SS')

as.POSIXct()

strava_endpoint <- oauth_endpoint(
  request = NULL,
  authorize = "authorize", 
  access = "token",
  base_url = "https://www.strava.com/api/v3/oauth/"
)

myapp <- oauth_app(
  "strava", # internal name, not related to api app name in strava
  key = 126618,  # client ID
  secret = Sys.getenv('STRAVA_SECRET') # client secret
)

mytok <- oauth2.0_token(
  endpoint = strava_endpoint, 
  app = myapp,
  scope = c("activity:read"),
  cache = TRUE
)

resp <- GET(glue("https://www.strava.com/api/v3/athlete/activities?per_page=200"), config(token = mytok))

dat <- fromJSON(rawToChar(resp$content))
