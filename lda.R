library(tosca)
library(ldaPrototype)

lda = getLDA(readRDS("corona100proto.rds"))
id = names(readRDS("corona100docs.rds"))
obj = readRDS("corpus/obj20200706.rds")

plotTopic(obj, lda, id, unit = "week", rel = TRUE)
plotArea(lda, id, meta = obj$meta, unit = "day", xunit = "month", legend = "topleft")
topWords(getTopics(lda), 20)

mat = topTexts(lda, id, 100)
showTexts(obj, mat, file = "topTexts/")

topwords = lda::top.topic.words(getTopics(lda), by.score = TRUE)
prop = round(rowSums(getTopics(lda)) / sum(getTopics(lda)) * 100, 4)
out = rbind(prop, topwords)
colnames(out) = paste("Topic", seq_len(15))
row.names(out) = c("Proportion (%)", 1:20)
write.csv(out, file = "topwords.csv", fileEncoding = "UTF-8")

tab = plotTopic(object = obj, ldaresult = lda, ldaID = id, unit = "day")
tabrel = plotTopic(object = obj, ldaresult = lda, ldaID = id, rel = TRUE, unit = "day")

write.csv(tab, file = "topics.csv", fileEncoding = "UTF-8", row.names = FALSE)
write.csv(tabrel, file = "topicsrel.csv", fileEncoding = "UTF-8", row.names = FALSE)

heatmap(t(as.matrix(tabrel[,-1])), Colv = NA, Rowv = NA)
