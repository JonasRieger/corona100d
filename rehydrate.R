library(rtweet)
token = readRDS(".rtweet_token.rds")
status = gsub("x", "", readLines("status_id.txt"))
##lasts around 10 hours##
a = Sys.time()
tweets = lookup_tweets(status[1:90000], token = token)
i = 90001
n = length(status)
while(i <= n){
  time = Sys.time()
  tweets = rbind(tweets, lookup_tweets(status[i:min((i+89999), n)], token = token))
  i = i+90000
  elapsed = difftime(Sys.time(), time, units = "mins")
  if(elapsed < 15 && i <= n) Sys.sleep(as.numeric(15 - elapsed)*60)
  Sys.sleep(10)
}
b = Sys.time()
saveRDS(tweets, file = "rehydrated.rds")
b-a
