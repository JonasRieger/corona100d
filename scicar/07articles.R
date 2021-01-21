message("articles.R")
starttime = Sys.time()

library(data.table)
library(tosca)
library(tm)
library(stringr)
library(spelling)

botdata = readRDS(file.path("scraping_articles", "botdata.rds"))
botdata = botdata[!is.na(url_text),]
scrapinghubdata = readRDS(file.path("scraping_articles", "scrapinghubdata.rds"))
scrapinghubdata = scrapinghubdata[!(url_new_expanded %in% botdata$url_new_expanded),]

articles = rbind(botdata, scrapinghubdata, fill = TRUE)

if("articles.rds" %in% list.files("corpus")){
  tmp = readRDS(file.path("corpus", "articles.rds"))
  articles = articles[!(url_new_expanded %in% tmp$url_new_expanded), ]
}

articles[, url_text_wordcount := str_count(url_text, "\\b[a-zA-Z](.*?)\\b")]
#utf8_umlaut = read.csv(file = file.path("corpus", "UTF_umlaut.csv"),
#  stringsAsFactors = FALSE)
#for (i in seq_len(nrow(utf8_umlaut)))
#  articles[, url_text := gsub(x = url_text, pattern = utf8_umlaut$actual[i],
#    replacement = utf8_umlaut$expected[i])]
articles[, url_text := removeUmlauts(url_text)]
system.time(articles[, url_text_gibberishcount := tabulate(unlist(spell_check_text(url_text,
  lang = file.path("corpus", "mydicumlauts"))$found), nbins = .N)])
articles[, url_text_gibberishrel := url_text_gibberishcount/url_text_wordcount]

if("articles.rds" %in% list.files("corpus")){
  articles = rbind(tmp[,-"id"], articles)
}

articles[, id := .GRP, by = url_text]

saveRDS(articles, file.path("corpus", "articles.rds"))

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

gc()
