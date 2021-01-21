message("expand.R")
starttime = Sys.time()

library(longurl)
library(data.table)
#url = readRDS(file.path("data", "url.rds"))

#nlist = list(ges = url[, .N])
#setkeyv(url, "downloaded")
#url = url[!duplicated(status_id, fromLast = TRUE)]
url = readRDS(file.path("data", "urlnodups.rds"))
nlist = list(ges = NA)

nlist[["notDup"]] = url[,.N]

splittedurls = strsplit(url$urls_expanded_url, " ")
splittedurls = lapply(splittedurls, unique)
url = url[rep(seq_along(splittedurls), times = lengths(splittedurls)),]
url[, url_new := unlist(splittedurls)]
nlist[["unlisted"]] = url[,.N]

unique_urls = unique(url$url_new)
nlist[["uniqueURL1"]] = length(unique_urls)

if("url_expand_table.rds" %in% list.files("data")){
  url_expand_table = readRDS(file.path("data", "url_expand_table.rds"))
}else{
  url_expand_table = data.table(
    url_new = character(0),
    url_new_expanded = character(0),
    url_status_code = integer(0))
}

to_expand = union(
  unique_urls[!unique_urls %in% url_expand_table$url_new],
  url_expand_table[is.na(url_status_code), url_new])

message(length(to_expand), " URLs")

a = Sys.time()
tmp = rbindlist(lapply(to_expand, function(x){
  o = try(expand_urls(x), silent = TRUE)
  if(class(o)[1] == "try-error") o = data.table(orig_url = x)
  o
}), fill = TRUE)
b = Sys.time()
message(difftime(b, a, units = "hours"), " hours")

expanded_url = tmp$expanded_url
status_code = tmp$status_code

message(sum(is.na(status_code)), " URLs")

a = Sys.time()
if(any(is.na(status_code))){
  a = Sys.time()
  tmp = rbindlist(lapply(to_expand[is.na(status_code)], function(x){
    o = try(expand_urls(x), silent = TRUE)
    if(class(o)[1] == "try-error") o = data.table(orig_url = x)
    o
  }), fill = TRUE)
  b = Sys.time()
  expanded_url[is.na(status_code)] = tmp$expanded_url
  status_code[is.na(status_code)] = tmp$status_code
}
b = Sys.time()
message(difftime(b, a, units = "hours"), " hours")

url_expand_table = rbind(
  url_expand_table[!is.na(url_status_code)],
  data.table(
    url_new = to_expand,
    url_new_expanded = expanded_url,
    url_status_code = status_code))

nlist[["statusCodeNotNA"]] = sum(!is.na(url_expand_table$url_status_code))
saveRDS(url_expand_table, file = file.path("data", "url_expand_table.rds"))

url = merge(url, url_expand_table, by = "url_new")

url_tmp = url$url_new_expanded
url_tmp[is.na(url$url_status_code)] = url$url_new[is.na(url$url_status_code)]

nlist[["uniqueURL2"]] = length(unique(url_tmp))

url$url_new_expanded[is.na(url$url_status_code)] = url$url_new[is.na(url$url_status_code)]

saveRDS(url, file = file.path("data", "urlExpanded.rds"))
saveRDS(nlist, file = file.path("data", "nURL.rds"))

message(difftime(Sys.time(), starttime, units = "hours"), " hours")

gc()

