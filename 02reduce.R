message("reduce.R")
starttime = Sys.time()

library(data.table)

file = list.files(path = "tweets")
done = readLines(file.path("data", "doneReduce.txt"))
file = setdiff(file, done)

if(length(file) > 0){

  ntable = list()
  reduced = list()

  for(i in file){
    message(i)
    downloaded = as.POSIXct(substr(i, 1, 14), format = "%Y%m%d%H%M%S")
    tweets = fread(file.path("tweets", i), stringsAsFactors = FALSE, encoding = "UTF-8")
    ntable[[i]] = data.table(
      downloaded = downloaded,
      n = tweets[, .N],
      nNoRetweet = tweets[is_retweet == FALSE, .N],
      nURL = tweets[urls_expanded_url != "", .N],
      nReduced = tweets[is_retweet == FALSE & urls_expanded_url != "", .N])
    tweets = tweets[is_retweet == FALSE]
    cols = c("user_id","status_id","name","lang","media_type","media_url",
      "urls_expanded_url","hashtags","favorite_count","retweet_count",
      "is_quote","is_retweet","source","text","screen_name")
    date = as.Date(tweets$created_at)
    time = gsub(x = tweets$created_at, pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2} ", replacement = "")
    tweets = tweets[, colnames(tweets) %in% cols, with = FALSE]
    tweets[, date := date]
    tweets[, time := time]
    tweets[, downloaded := downloaded]
    reduced[[i]] = tweets
  }

  ntable = rbindlist(ntable)
  reduced = rbindlist(reduced)

  url = reduced[urls_expanded_url != ""]

  if(length(done) > 0){
    saveRDS(rbind(readRDS(file.path("data", "ntable.rds")), ntable),
      file = file.path("data", "ntable.rds"))
    
    url = rbind(readRDS(file.path("data", "url.rds")), url)
    saveRDS(url, file = file.path("data", "url.rds"))
    setkeyv(url, "downloaded")
    url = url[!duplicated(status_id, fromLast = TRUE)]
    saveRDS(url, file = file.path("data", "urlnodups.rds"))
    
    reduced = rbind(readRDS(file.path("data", "reduced.rds")), reduced)
    saveRDS(reduced, file = file.path("data", "reduced.rds"))
    setkeyv(reduced, "downloaded")
    reduced = reduced[!duplicated(status_id, fromLast = TRUE)]
    saveRDS(reduced, file = file.path("data", "reducednodups.rds"))
  }else{
    saveRDS(reduced, file = file.path("data", "reduced.rds"))
    saveRDS(url, file = file.path("data", "url.rds"))
    saveRDS(ntable, file = file.path("data", "ntable.rds"))
  }

  writeLines(c(done, file), con = file.path("data", "doneReduce.txt"))
}

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

rm(list = ls())

gc()
