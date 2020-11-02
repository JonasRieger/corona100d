library(RCurl)
library(RJSONIO)
library(data.table)

diffbot = function(url, token){
  # load R libraries
  #require(RCurl)
  #require(RJSONIO)
  api = 'analyze'
  api_url = 'http://api.diffbot.com/'
  version = 2
  # request urls
  request = paste0(api_url, paste0("v", version, "/"), api, '?token=', token,
    "&url=", URLencode(url, reserved = TRUE, repeated = TRUE))
  # get data
  response = getURL(request)
  # json to R list
  data = tryCatch(fromJSON(response), error = function(e) "error")
  # repeat once
  if(data[[1]] == "error") data = tryCatch(fromJSON(response), error = function(e) "error")
  if(!("text" %in% names(data))){
    return(data.table(
      url_new_expanded = url,
      url_date = as.Date(NA),
      url_hour = NA_integer_,
      url_min = NA_integer_,
      url_sec = NA_integer_,
      url_lang = ifelse("human_language" %in% names(data), data[["human_language"]], NA_character_),
      url_text = NA_character_,
      url_type = ifelse("type" %in% names(data), data[["type"]], NA_character_),
      url_title = ifelse("title" %in% names(data), data[["title"]], NA_character_),
      url_tags = NA_character_,
      url_image_count = NA_integer_,
      stringsAsFactors = FALSE))
  }
  if(!("date" %in% names(data))) data$date = as.Date(NA)
  if(!("human_language" %in% names(data))) data$human_language = NA_character_
  if(!("type" %in% names(data))) data$type = NA_character_
  if(!("title" %in% names(data))) data$title = NA_character_
  if(!("tags" %in% names(data))) data$tags = NA_character_
  if(!("images" %in% names(data))) data$images = list()
  posix = as.POSIXlt(data$date, format = "%a, %d %b %Y %T GMT")
  ret = data.table(
    url_new_expanded = url,
    url_date = as.Date(data$date, format = "%a, %d %b %Y %T GMT"),
    url_hour = posix$hour,
    url_min = posix$min,
    url_sec = posix$sec,
    url_lang = data$human_language,
    url_text = data$text,
    url_type = data$type,
    url_title = data$title,
    url_tags = paste(data$tags, collapse = "+++"),
    url_image_count = length(data$images),
    stringsAsFactors = FALSE)
  return(ret)
}
