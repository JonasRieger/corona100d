message("build_corpus.R")
starttime = Sys.time()

library(data.table)
library(urltools)
library(tosca)
library(tm)

articles = readRDS(file.path("corpus", "articles.rds"))
url = readRDS(file.path("data", "urlExpanded.rds"))
url = merge(url, articles, "url_new_expanded", all = TRUE)

url[, url_core := suffix_extract(url_parse(gsub("@", "", url_new_expanded))$domain)$domain]
url[, tweet_count := .N, by = id]
url[, user_count := length(unique(user_id)), by = id]
url[, tweet_hashtags := stripWhitespace(paste(hashtags, collapse = " ")), by = id]
url[, tweet_text := stripWhitespace(paste(text, collapse = " ")), by = id]
url[, favorite_sum := sum(as.integer(favorite_count))+.N, by = id]
url[, retweet_sum := sum(as.integer(retweet_count))+.N, by = id]
url[, favorite_sum_core := sum(as.integer(favorite_count))+.N, by = url_core]
url[, retweet_sum_core := sum(as.integer(retweet_count))+.N, by = url_core]

url[, corpus_flag := !(url_core %in% c("twitter", "instagram", "youtube", "youtu")) &
    (retweet_sum > 9 | favorite_sum > 9) &
    !is.na(url_new_expanded) &
    url_text_wordcount > 20 &
    url_text_gibberishrel < 0.3]

label = fread(file.path("label", "label_core.csv"), stringsAsFactors = FALSE)
url_core_label = label[match(url$url_core, label$url_core), "url_core_label", with = FALSE]
url[, url_core_label := as.character(url_core_label$url_core_label)]

codebook = fread(file.path("label", "codebook.csv"), stringsAsFactors = FALSE)
url_core_label_ldagroup = codebook[match(url$url_core_label, codebook$url_core_label),
  "url_core_label_ldagroup", with = FALSE]
url[, url_core_label_ldagroup := as.character(url_core_label_ldagroup$url_core_label_ldagroup)]

#saveRDS(url, file.path("corpus", "urlText.rds"))

url = url[corpus_flag == TRUE,]

tab = unique(merge(
  url[, c("url_core_label", "url_core")],
  url[, .N, by = "url_core"],
  by = "url_core"))
setorderv(tab, "N", -1)
tab = tab[N > 10, ]
tab[, exampleURL := sapply(tab$url_core, function(x)
  sample(url[url_core == x, url_new_expanded], 1))]
fwrite(tab, file = file.path("label", "label_core_ges.csv"))
fwrite(tab[is.na(url_core_label) == TRUE, ],
  file = file.path("label", "label_core_neu.csv"))

url[, status_ids := paste0(status_id, collapse = ","), by = id]
url[, status_count := length(status_id), by = id]
url[, user_ids := paste0(user_id, collapse = ","), by = id]
url[, user_count := length(unique(user_id)), by = id]
url[, mindate := min(date), by = id]
url = url[date == mindate, ]
url[, mintime := min(time), by = id]
url = url[time == mintime, ]
url[, mindownloaded := min(downloaded), by = id]
url = url[downloaded == mindownloaded, ]
url[, maxretweet := max(retweet_count), by = id]
url = url[retweet_count == maxretweet, ]
url[, maxfavs := max(favorite_count), by = id]
url = url[favorite_count == maxfavs, ]

# falls dann immer noch mehrere pro ID:
url[, sampledstatusid := sample(status_id, 1), by = id]
url = url[status_id == sampledstatusid, ]
# falls dann immer noch mehrere pro ID
# (nur moeglich, falls ein Tweet mehrmals den gleichen Text verlinkt):
url[, sampledurl := sample(url_new, 1), by = id]
url = url[url_new == sampledurl, ]

url = url[, c("id",
  "status_id", "status_ids", "status_count",
  "user_id", "user_ids", "user_count",
  "date", "time", "downloaded",
  "url_new_expanded", "url_core", "url_core_label", "url_core_label_ldagroup",
  "user_count", "tweet_count",
  "tweet_text", "tweet_hashtags", "favorite_sum", "retweet_sum",
  "favorite_sum_core", "retweet_sum_core",
  "url_status_code", "url_date", "url_hour", "url_min", "url_sec", "url_lang",
  "url_text", "url_type", "url_title", "url_image_count", "url_probability",
  "url_text_wordcount", "url_text_gibberishcount", "url_text_gibberishrel")]

text = as.list(url$url_text)
meta = copy(url)
meta[, url_text := NULL]
meta[, title := url_title]
meta[, url_title := NULL]
meta[, id := as.character(id)]
names(text) = meta$id

obj = textmeta(meta = meta, text = text)
utf8 = unlist(lapply(obj$text, function(x) lapply(x, validUTF8)))
sum(!utf8)
#1
obj = filterID(obj, names(obj$text)[utf8])
saveRDS(obj, file.path("corpus", "obj.rds"))

obj$text[[obj$meta$id[obj$meta$status_id == "x1278218812056313856"]]] = 
  gsub(pattern = "Erho(.?)*lung", replacement = "Erholung",
       obj$text[[obj$meta$id[obj$meta$status_id == "x1278218812056313856"]]])
clean = cleanTexts(obj, sw = "de")
maxwords = 1000
clean$text[lengths(clean$text) > maxwords] = lapply(
  clean$text[lengths(clean$text) > maxwords], function(x) sample(x, maxwords))
saveRDS(clean, file.path("corpus", "clean.rds"))

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

gc()

