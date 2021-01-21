library(data.table)
library(urltools)

obj = readRDS(file.path("data", "reducednodups20200706.rds"))
obj = obj[obj$date > as.Date("2020-03-18") & obj$date < as.Date("2020-03-19")+100]
obj$is_quote = as.logical(obj$is_quote)
obj$is_retweet = as.logical(obj$is_retweet)
obj$favorite_count = as.integer(obj$favorite_count)
obj$retweet_count = as.integer(obj$retweet_count)

urls = strsplit(obj$urls_expanded_url, " ")

expand_table = readRDS(file.path("data", "url_expand_table.rds"))
ind = rep(1:length(urls), lengths(urls))
tmp = expand_table$url_new_expanded[match(unlist(urls), expand_table$url_new)]
tmp[is.na(tmp)] = unlist(urls)[is.na(tmp)]
splitted = split(tmp, ind)
l = list()
l[unique(ind)] = splitted
obj$urls = l

tmp = suffix_extract(url_parse(gsub("@", "", tmp))$domain)$domain
splitted = split(tmp, ind)
l = list()
l[unique(ind)] = splitted
obj$url_cores = l

saveRDS(obj, file = "corona100.rds")


######

obj = readRDS(file = "corona100.rds")

length(unique(obj$status_id)) # number of unique tweets
# [1] 3699623

length(unique(obj$user_id)) # number of unique users
# [1] 397283
count = tabulate(as.numeric(table(obj$user_id)))
count[1] # number of unique users with a single tweet in the dataset
# [1] 180187
count[2:10] # and so on...
# [1] 57415 30920 20055 14393 10930  8417  7099  5736  4849
count = table(as.numeric(table(obj$user_id)))
tail(count) # the 6 most often appearing users in the dataset (4474 times, ...)
# 4474 4490 5077 5194 5266 8151 
ids = head(sort(table(obj$user_id), decreasing = TRUE), 10)
rbindlist(lapply(names(ids), function(i){
  tmp = obj[user_id == i, c("name", "screen_name")]
  unique(tmp[, N := .N])
}))
#                            name     screen_name    N
#1:            Franz W.Winterberg    FWWinterberg 8151
#2:                          WELT            welt 5266
#3: Frankfurter Allgemeine gesamt         FAZ_NET 5194
#4:           Deutschland Germany Deutschland_BRD 5077
#5:      Alfred Hampp - Redakteur     AlfredHampp 4490
#6:          FOCUS Online TopNews   FOCUS_TopNews 4474
#7:                       Gnutiez         gnutiez 4141
#8:                  Tagesspiegel    Tagesspiegel 3915
#9:                Marco Herrmann   Kleeblatt1977 3838
#10:             FOCUS Gesundheit focusgesundheit 3635


table(obj$is_retweet) # no retweets
#   FALSE 
# 3699623 
table(obj$is_quote) # few quotes
#   FALSE    TRUE 
# 3484669  214954 

summary(obj$favorite_count)
#   Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 0.000     0.000     0.000     5.997     2.000 24841.000 
count = table(obj$favorite_count)
head(count) # almost 2 million tweets without favs
#       0       1       2       3       4       5 
# 1861340  644920  314757  180881  119195   84784 
tail(count) # maximal number of favs is 24841
# 15133 15568 17281 17866 19121 24841 

summary(obj$retweet_count)
#    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#  0.000    0.000    0.000    1.373    0.000 7592.000 
count = table(obj$retweet_count)
head(count) # almost 3 milltion tweets without retweet
#       0       1       2       3       4       5 
# 2849012  377547  149529   79690   50914   35171 
tail(count) # maximal number of retweets is 7592
# 2981 3011 3776 3832 4250 7592 

count = table(obj$date)
summary(as.numeric(count)) # there are at least 13863 tweets and at most 87577 tweets per day
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 13863   22587   35707   36996   48623   87577 
plot(count) # clear weekly seasonality

table(obj$media_type) # there are a number of tweets with (multiple) photos
#                              photo             photo photo       photo photo photo photo photo photo photo 
#    3151128                  548259                     229                       5                       2

sum(obj$hashtags != "") # number of tweets that used hashtags
# [1] 1478733
sum(obj$hashtags == "") # number of tweets that does not used hashtags
# [1] 2220890

secs = colSums(sapply(strsplit(obj$time, ":"), as.integer) * c(60*60, 60, 1))
summary(secs/60/60)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.000   9.116  13.016  13.195  17.332  24.000
hist(secs/60/60, xlab = "Stunde", ylab = "Häufigkeit", main = "")
# in the night less tweets ...

hist(obj$downloaded, breaks = 101)
table(as.numeric(as.Date(obj$downloaded) - obj$date))
#       0       1       2 
# 1759317 1827588  112718 
# every tweet is at max two days old at the download day

table(lengths(obj$urls)) # number of shared contents (urls)
#       0       1       2       3       4       5       6       7       8       9      10 
# 1657212 1952921   80951    6000    1743     500     168      46      47      23      12 
length(unique(unlist(obj$url_cores))) # more than 50k different "sources" for content
# [1] 54134
count = table(unlist(lapply(obj$url_cores, unique)))
count2 = table(count)
head(count2) # half of the sources is shared only once
#     1     2     3     4     5     6 
# 25611  8049  4076  2524  1749  1351 
tail(count2)
# 44450  54072  63032  76355 101978 217852 
head(sort(count, decreasing = TRUE), 10) # most shared sources
# twitter      youtube      spiegel        focus          faz sueddeutsche         zeit         welt         bild   tagesschau 
#  217852       101978        76355        63032        54072        44450        43550        43199        40179        28483 
