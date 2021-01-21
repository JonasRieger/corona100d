library(rtweet)
token = readRDS(".rtweet_token.rds")
status = gsub("x", "", readLines("status_id.txt"))
##lasts around 10 hours##
a = Sys.time()
tweets = lookup_tweets(status, token = token)
b = Sys.time()
saveRDS(tweets, file = "rehydrated.rds")
b-a
