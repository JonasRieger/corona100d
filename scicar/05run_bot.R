message("run_bot.R")
starttime = Sys.time()

library(data.table)

pro = TRUE

setwd("scraping_articles")

cand = readRDS("diffbot_candidates.rds")
to_diffbot = cand$to_scrape[cand$times_scraped < 4]

if("botdata.rds" %in% list.files()){
  tmp = readRDS("botdata.rds")
  tmp = tmp[!is.na(tmp$url_text),]
  to_diffbot = setdiff(to_diffbot, tmp$url_new_expanded)
}

if(pro){
  token = readLines("tokenpro.txt")
}else{
  token = readLines("token.txt")
}

#Sys.setlocale("LC_ALL","English")
source("diffbot_function.R")

message(length(to_diffbot), " URLs")
system.time(botdata <- do.call(rbind, lapply(to_diffbot, diffbot, token = token)))

if("botdata.rds" %in% list.files()){
  botdata = rbind(tmp, botdata)
}

cand[to_scrape %in% to_diffbot, times_scraped := times_scraped+1]
cand[to_scrape %in% botdata[is.na(url_text), url_new_expanded]
  & times_scraped == 4, times_scraped := 5]
saveRDS(cand, file = "diffbot_candidates.rds")

saveRDS(botdata, file = "botdata.rds")

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

gc()

