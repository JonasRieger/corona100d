## load rtweet package
library(rtweet)
library(lubridate)
token = readRDS(".rtweet_token.rds")

repeat({
  ##create timeobject##
  nextTimeScrape = Sys.time()
  hour(nextTimeScrape) = hour(nextTimeScrape) + 1
  minute(nextTimeScrape) = 30
  second(nextTimeScrape) = 0
  time = Sys.time()
  ##download tweets##
  rt = try(search_tweets(
    "coronavirusde OR corona OR coronavirus OR covid19 OR covid OR pandemie OR epidemie OR virus OR SARSCoV2",
    n = 50000, lang = "de", include_rts = TRUE, token = token, retryonratelimit = TRUE))
  ##repeat (max 3) if failed##
  trys = 1
  while(class(rt)[1] == "try-error" && trys < 3 && Sys.time() + 10*60 < nextTimeScrape){
    time = Sys.time()
    rt = try(search_tweets(
      "coronavirusde OR corona OR coronavirus OR covid19 OR covid OR pandemie OR epidemie OR virus OR SARSCoV2",
      n = 50000, lang = "de", include_rts = TRUE, token = token, retryonratelimit = TRUE))
    trys = trys+1
  }

  ##savetweets##
  filename = paste(gsub(" ", "", gsub("-", "", gsub(":", "", time))), "lido.csv", sep = "")
  save_as_csv(rt, file_name = file.path("tweets", filename))
  while(Sys.time() < nextTimeScrape){
    Sys.sleep(60)
  }
})
