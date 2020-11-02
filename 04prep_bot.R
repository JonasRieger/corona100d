message("prep_bot.R")
starttime = Sys.time()

library(data.table)
library(urltools)

nURL = readRDS(file.path("data", "nURL.rds"))
url = readRDS(file.path("data", "urlExpanded.rds"))

url$url_new_expanded[is.na(url$url_status_code)] = url$url_new[is.na(url$url_status_code)]

url[, favorite_sum := sum(as.integer(favorite_count))+length(favorite_count), by = url_new_expanded]
url[, retweet_sum := sum(as.integer(retweet_count))+length(retweet_count), by = url_new_expanded]
url[, url_core := suffix_extract(url_parse(gsub("@", "", url_new_expanded))$domain)$domain]
url[, retweet_sum_core := sum(as.integer(retweet_count))+length(retweet_count), by = url_core]

#### ein paar stats
d = url[retweet_sum_core>50, sample(url_new_expanded, 1), by = url_core]
setorderv(d, "url_core")
write.table(d, file.path("temp_data", "prefix.txt"),
  row.names = FALSE, quote = FALSE)

core_url_sums = unique(url[, c("url_core", "retweet_sum_core")])
setorderv(core_url_sums, "retweet_sum_core", order = -1)
write.table(core_url_sums, file.path("temp_data", "KernURLSums.txt"),
  row.names = FALSE, quote = FALSE)

core_urls = unique(url[, c("url_new_expanded", "retweet_sum", "url_core")])
tab = core_urls[retweet_sum > 9, table(url_core)]

write.table(sort(tab[tab>9], decreasing = T), file.path("temp_data", "KernURL.txt"),
  row.names = FALSE, quote = FALSE)

nURL[["core_urls"]] = nrow(core_url_sums)
nURL[["core_urls9"]] = length(tab)
nURL[["core_urls9.9"]] = length(tab[tab > 9])
####

to_scrape = url[!(url_core %in% c("twitter", "instagram", "youtube", "youtu")) &
    (retweet_sum > 9 | favorite_sum > 9) &
    !is.na(url_new_expanded), unique(url_new_expanded)]
nURL[["to_scrape"]] = length(to_scrape)

saveRDS(nURL, file = file.path("data", "nURL.rds"))
cand = data.table(to_scrape = to_scrape, times_scraped = 0L, scrapinghub = FALSE)

if("diffbot_candidates.rds" %in% list.files("scraping_articles")){
  cand = rbind(cand,
    readRDS(file.path("scraping_articles", "diffbot_candidates.rds")))
  cand[, times_scraped := max(times_scraped), by = to_scrape]
  cand[, scrapinghub := any(scrapinghub), by = to_scrape]
  cand = unique(cand)
}
saveRDS(cand, file = file.path("scraping_articles", "diffbot_candidates.rds"))

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

gc()
