message("run_scrapinghub.R")
starttime = Sys.time()

library(data.table)

setwd("scraping_articles")

cand = readRDS("diffbot_candidates.rds")
# times_scraped == 5, falls viermal fehlerhaft mit diffbot gescraped
to_diffbot = cand[times_scraped > 4 & scrapinghub == FALSE, to_scrape]
if(length(to_diffbot) > 9000) to_diffbot = to_diffbot[1:9000]
# kostenfreier Token nur für 10k Anfragen
  
token = readLines("scrapinghubtoken.txt")

#Sys.setlocale("LC_ALL","English")
source("scrapinghub_function.R")

message(length(to_diffbot), " URLs")
system.time(botdata <- do.call(rbind, lapply(to_diffbot, scrapinghub, token = token)))

if("scrapinghubdata.rds" %in% list.files()){
  botdata = rbind(readRDS("scrapinghubdata.rds"), botdata)
}

cand[to_scrape %in% to_diffbot, scrapinghub := TRUE]
saveRDS(cand, file = "diffbot_candidates.rds")

saveRDS(botdata, file = "scrapinghubdata.rds")

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

gc()
