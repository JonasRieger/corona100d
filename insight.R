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

library(data.table)
library(lubridate)
library(ggplot2)

length(unique(obj$status_id)) # number of unique tweets
# [1] 3699623

length(unique(obj$user_id)) # number of unique users
# [1] 397283
count = tabulate(as.numeric(table(obj$user_id)))
count[1] # number of unique users with a single tweet in the dataset
# [1] 180187
count[2:10] # and so on...
# [1] 57415 30920 20055 14393 10930  8417  7099  5736  4849
ids = head(sort(table(obj$user_id), decreasing = TRUE), 13)
tab = rbindlist(lapply(names(ids), function(i){
  tmp = obj[user_id == i, .(name = name, screen_name = screen_name,
                            url_cores = url_cores, favs = mean(favorite_count),
                            rts = mean(retweet_count), quote = mean(is_quote),
                            links = 1-mean(sapply(urls, is.null)),
                            hashtags = mean(hashtags != ""))]
  tab = table(unlist(tmp$url_cores))
  tmp[, url_cores := NULL]
  tmp[, fav_url := names(which.max(tab))]
  tmp[, fav_url_ratio := max(tab/sum(tab))]
  unique(tmp[, N := .N])
}))

count = table(unlist(obj$url_cores))
tab = rbind(tab,
            obj[, .(name = "all", screen_name = "all", favs = mean(favorite_count),
                    rts = mean(retweet_count), quote = mean(is_quote),
                    links = 1-mean(sapply(urls, is.null)), hashtags = mean(hashtags != ""),
                    fav_url = names(which.max(count)), fav_url_ratio = max(count/sum(count)), N = .N)])

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
head(count) # almost 3 million tweets without retweet
#       0       1       2       3       4       5 
# 2849012  377547  149529   79690   50914   35171 
tail(count) # maximal number of retweets is 7592
# 2981 3011 3776 3832 4250 7592 

count = table(obj$date)
summary(as.numeric(count)) # there are at least 13863 tweets and at most 87577 tweets per day
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 13863   22587   35707   36996   48623   87577 
plot(count) # clear weekly seasonality

Sys.setlocale("LC_ALL","English")
dat = data.table(date = as.Date(names(count)), N = as.numeric(count))
dat[, weekday := factor(weekdays(date), levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))]
ggplot(dat) + aes(x = date, y = N) + geom_line() +
  geom_line(aes(x = date, y  = N, col = weekday)) + ylim(c(0, max(dat$N))) +
  xlab("Date") + ylab("Number of tweets") + labs(col = "Day of Week")

library(ggwordcloud)

mywordcloud = function(day = "2020-06-16", seed = 12){
  hashtags = tolower(unlist(strsplit(obj[date == day]$hashtags, " ")))
  secondary = hashtags[!hashtags %in% c("corona", "coronavirus", "coronakrise", "covid19", "covid_19",
                                        "coronavirusde", "coronadeutschland", "coronavirusdeutschland",
                                        "covid19deutschland", "covid2019de", "sarscov2", "covid_19de",
                                        "covid", "viruscorona", "sars_cov_2", "covid__19", "covid19de",
                                        "covid...19", "deutschland", "covid2019", "covidー19",
                                        "covid<u+30fc>19")]
  secondary = table(tosca::removeUmlauts(secondary))
  top = sort(secondary, decreasing = TRUE)[35]
  words = names(secondary)[secondary >= top]
  freq = secondary[secondary >= top]
  set.seed(seed)
  ggwordcloud2(data.table(word = words, freq = (as.numeric(freq))^0.5), shuffle = F)
}
# coronawarnapp
mywordcloud("2020-06-16") + ggtitle("2020/06/16 (Tuesday)")
# toennies
mywordcloud("2020-06-17") + ggtitle("2020/06/17 (Wednesday)")

# time of day plot
obj[, time_num := sapply(strsplit(time, ":"), function(x) sum(as.numeric(x) / c(1,60,60*60)))]
ids_time = head(sort(table(obj$user_id), decreasing = TRUE), 5)
ggplot() + 
  geom_density(data = obj, aes(x = time_num)) +
  geom_density(data = obj[user_id %in% names(ids_time)],
               aes(x = time_num,  col = screen_name)) +
  xlab("Time of Day") + ylab("Density") + labs(col = "Top 5 User")

table(obj$media_type) # there are a number of tweets with (multiple) photos
#                              photo             photo photo       photo photo photo photo photo photo photo 
#    3151128                  548259                     229                       5                       2

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
ids = names(head(sort(count, decreasing = TRUE), 13)) # most shared sources

tab = rbindlist(lapply(ids, function(i){
  tmp = obj[sapply(url_cores, function(x) i %in% x), ]
  count = table(tmp$user_id)
  name_tmp = unique(tmp[user_id == names(which.max(count)), screen_name])
  tmp = tmp[, .(source = i, N = .N,
                unique_ids = length(names(count)),
                fav_screen_name = name_tmp,
                fav_id_ratio = max(count/sum(count)))]
}))
