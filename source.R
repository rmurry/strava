library(dplyr)
library(httr)
library(jsonlite)

strava_endpoint <- oauth_endpoint(
  request = NULL,
  authorize = "authorize", 
  access = "token",
  base_url = "https://www.strava.com/api/v3/oauth/"
)

myapp <- oauth_app(
  "strava", 
  key = 126618,  # <- change this to your strava ID 
  secret = "6d4056b400b9042651c93c85fbf5cfbffe6e0694" # <- change this to your client ID
)

mytok <- oauth2.0_token(
  endpoint = strava_endpoint, 
  app = myapp,
  scope = c("activity:read"), # somehow it does not work with multiple scopes
  cache = TRUE
)

resp <- GET("https://www.strava.com/api/v3/athlete/activities", config(token = mytok))

dat <- fromJSON(rawToChar(resp$content))
