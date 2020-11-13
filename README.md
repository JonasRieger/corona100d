# corona100d
### Best Practices bei der Genese, Analyse und Publikation eines Open-Data-Korpus

This repository provides the data and scripts related to the talk

* von Nordheim, G. & Rieger, J. (2020). corona100d - Best practices in the creation process, analysis and publication of an open data corpus [corona100d – Best Practices bei der Genese, Analyse und Publikation eines Open-Data-Korpus]. [*SciCAR 2020*](https://sched.co/ejkZ).

For bug reports, comments and questions please use the [issue tracker](https://github.com/JonasRieger/corona100d/issues).

## Related Software
* [rtweet](https://github.com/ropensci/rtweet) to scrape tweets.
* [longurl](https://github.com/hrbrmstr/longurl) to expand short urls.
* [urltools](https://github.com/Ironholds/urltools) to extract url cores from urls.
* [tosca](https://github.com/Docma-TU/tosca) to manage and manipulate the text data to a structure requested by ``ldaPrototype``.
* [ldaPrototype](https://github.com/JonasRieger/ldaPrototype) to determine a prototype from a number of runs of Latent Dirichlet Allocation.
* [batchtools](https://github.com/mllg/batchtools) to calculate (prototypes of) LDAs on the High Performace Compute Cluster [LiDO3](https://www.lido.tu-dortmund.de/cms/en/LiDO3/index.html).
* [data.table](https://github.com/Rdatatable/data.table) to manage data tables.
* [lubridate](https://lubridate.tidyverse.org/) to handle dates.
* [tm](https://CRAN.R-project.org/package=tm) and [stringr](https://stringr.tidyverse.org/articles/from-base.html) to preprocess the text data.
* [spelling](https://github.com/ropensci/spelling) to identify gibberish in texts.
* [RCurl](https://uribo.github.io/rpkg_showcase/web/RCurl.html) and [RJSONIO](https://github.com/duncantl/RJSONIO) to scrape articles with [diffbot](https://www.diffbot.com/).
* [httr](https://github.com/r-lib/httr) to scrape articles with [scrapinghub](https://www.scrapinghub.com/).
* [RColorBrewer](https://cran.r-project.org/package=RColorBrewer) and [ggwordcloud](https://github.com/lepennec/ggwordcloud) to visualize some statistics.

## Usage
Please note: For legal reasons the repository cannot provide all data. Please [let us know](https://github.com/JonasRieger/corona100d/issues) if you feel that there is anything missing that we could add. 

The numbered scripts describe the general workflow during data set creation. In the folder ``scraping_articles`` are the parsers for the article scrapers.
The two ``txt`` files (``status_id.txt`` and ``status_id_Articles.txt``) specify the 3,699,623 status ids of the tweets in the base data set and the status ids of the filtered data set (tweets with links) on which a LDA was calculated (85,920 ids).

The scripts ``corona100d.R`` and ``wordcloud.R`` give an first insight into the base dataset ``corona100d`` (see also ``wordclouds.pdf`` and ``counts.pdf``), while ``corona100dArticles.R`` contains code to fit LDAs. The necessary data to model the LDA are given by ``docs.rds`` and ``vocab.rds``; ``lda.R`` then shows code for a minimal evaluation of the LDA results
