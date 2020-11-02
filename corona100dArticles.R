library(tosca)
library(ldaPrototype)

obj = readRDS("corpus/obj20200706.rds")
obj = filterDate(obj, s.date = as.Date("2020-03-19"), e.date = as.Date("2020-03-19")+99)

plot(obj, unit = "day")

clean = cleanTexts(obj, sw = "de")

wl = makeWordlist(clean$text)
vocab = wl$words[wl$wordtable > 20]

docs = LDAprep(clean$text, vocab) # one empty article is deleted

saveRDS(docs, "corona100docs.rds") # sorted for upload...
saveRDS(vocab, "corona100vocab.rds")

if(FALSE){
  # one single LDA
  res = getLDA(LDARep(docs, vocab, n = 1, K = 10)) # should run less than 20 minutes
  
  # LDAPrototype locally
  res = LDAPrototype(docs, vocab, K = 10, n = 50, pm.backend = "socket")
  # should run less than 20(=singleLDA)*50(=n) minutes = 17 hours
  # is parallelized... so runtime decreases in number of CPU cores
  
  # LDAPrototype on Batch systems
  res = LDABatch(docs, vocab, K = 15, id = "corona100dBatch",
    resources = list(walltime = 2*60*60, memory = 8000))
  # wait for completion...
  proto = getPrototype(res, pm.backend = "socket")
  saveRDS(proto, "corona100proto.rds")
}
