library(data.table)
library(RColorBrewer)
#library(wordcloud)
library(ggwordcloud)

obj = readRDS(file.path("data", "reducednodups20200706.rds"))
obj = obj[obj$date > as.Date("2020-03-18") & obj$date < as.Date("2020-03-19")+100]

tmp = table(obj$date)

tab = data.table(date = as.Date(names(tmp)), count = as.numeric(tmp))
tab = head(tail(tab, -1), -1)
tab[, wday :=  wday(date)] # Sonntag = 1

pdf("counts.pdf", height = 6, width = 10)
par(mar = c(4.2,4.2,0.5,0.5))
plot(tab$date, tab$count/1000, type = "h", ylim = c(0, max(tab$count/1000)),
  xlab = "Date in 2020", ylab = "# Tweets (in thousands)")
col = brewer.pal(8, "Dark2")[2:8]
for(day in 1:7){
  points(tab[wday == day]$date, tab[wday == day]$count/1000,
    col = col[day], pch = 20)
}
legend("top", horiz = T, c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
  col = col, pch = 20, bty = "n")
dev.off()


# Hashtag-Wordclouds
hashtags = lapply(tab$date,
  function(x) tolower(unlist(strsplit(obj[date == x]$hashtags, " "))))
levels = unique(unlist(lapply(hashtags, unique)))
hashtagtab = do.call(cbind, lapply(hashtags,
  function(x) table(factor(x, levels = levels))))
colnames(hashtagtab) = as.character(tab$date)
rm(obj)

id = rownames(hashtagtab) %in%
  c("corona", "coronavirus", "coronakrise", "covid19", "covid_19",
    "coronavirusde", "coronadeutschland", "coronavirusdeutschland",
    "covid19deutschland", "covid2019de", "sarscov2", "covid_19de",
    "covid", "viruscorona", "sars_cov_2", "covid__19", "covid19de",
    "covid...19", "deutschland", "covid2019", "covidー19",
    "covid<u+30fc>19")
redtab = hashtagtab[!id,]

hashtagtab = redtab

pdf("wordclouds.pdf", height = 5, width = 12)
set.seed(20201102)
words = rownames(hashtagtab)
freq = rowSums(hashtagtab)
id = freq > 2600
tmp = ggwordcloud(words[id], freq[id])
plot(tmp)
id = freq > 2700
tmp = ggwordcloud(words[id], freq[id])
plot(tmp)
id = freq > 2800
tmp = ggwordcloud(words[id], freq[id])
plot(tmp)
id = freq > 2900
tmp = ggwordcloud(words[id], freq[id])
plot(tmp)
id = freq > 3000
tmp = ggwordcloud(words[id], sqrt(freq[id]))
plot(tmp)
id = freq > 4000
tmp = ggwordcloud(words[id], sqrt(freq[id]))
plot(tmp)
id = freq > 5000
tmp = ggwordcloud(words[id], sqrt(freq[id]))
plot(tmp)

if(FALSE){
  for(i in 1:ncol(hashtagtab)){
    freq = hashtagtab[,i]
    id = freq > 100
    tmp = ggwordcloud(words[id], freq[id])
    plot(tmp)
  }
}
dev.off()

