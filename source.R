library(dplyr)
library(rStrava)
library(httr)


stoken <- httr::config(token = strava_oauth('custom_app', '126618', '6d4056b400b9042651c93c85fbf5cfbffe6e0694', cache = TRUE))
my_acts <- get_activity_list(stoken)
act_data <- compile_activities(my_acts)
chk_nopolyline(act_data)