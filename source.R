library(dplyr)
library(rStrava)
library(httr)


stoken <- httr::config(token = strava_oauth(app_name, client_id, client_secret, cache = TRUE))
my_acts <- get_activity_list(stoken)
act_data <- compile_activities(my_acts)
chk_nopolyline(act_data)