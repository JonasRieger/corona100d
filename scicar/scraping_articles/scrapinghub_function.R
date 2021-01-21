library(data.table)
library(httr)

scrapinghub = function(url, token){
  # get data
  request = paste0('[{"url": "', url, '", "pageType": "article"}]')
  response = POST(url = 'https://autoextract.scrapinghub.com/v1/extract',
    add_headers(.headers=c("Content-Type" = 'application/json')),
    body = request,
    authenticate(token, ''))
  # json to R list
  data = content(response, encoding = "UTF-8")
  if(!("article" %in% names(data[[1]])) ||
      !("articleBody" %in% names(data[[1]]$article))){
    return(data.table(
      url_new_expanded = url,
      url_date = as.Date(NA),
      url_hour = NA_integer_,
      url_min = NA_integer_,
      url_sec = NA_integer_,
      url_lang = NA_character_,
      url_text = NA_character_,
      url_title = NA_character_,
      url_desc = NA_character_,
      url_author = NA_character_,
      url_image_count = NA_integer_,
      url_probability = NA_real_,
      stringsAsFactors = FALSE))
  }
  data = data[[1]]$article
  if(!("datePublished" %in% names(data))) data$datePublished = as.Date(NA)
  if(!("inLanguage" %in% names(data))) data$inLanguage = NA_character_
  if(!("description" %in% names(data))) data$description = NA_character_
  if(!("headline" %in% names(data))) data$headline = NA_character_
  if(!("author" %in% names(data))) data$author = NA_character_
  if(!("images" %in% names(data))) data$images = list()
  posix = as.POSIXlt(data$datePublished, format = "%Y-%m-%dT%T")
  ret = data.table(
    url_new_expanded = url,
    url_date = as.Date(data$datePublished),
    url_hour = posix$hour,
    url_min = posix$min,
    url_sec = posix$sec,
    url_lang = data$inLanguage,
    url_text = data$articleBody,
    url_title = data$headline,
    url_desc = data$description,
    url_author = data$author,
    url_image_count = length(data$images),
    url_probability = data$probability,
    stringsAsFactors = FALSE)
  return(ret)
}
