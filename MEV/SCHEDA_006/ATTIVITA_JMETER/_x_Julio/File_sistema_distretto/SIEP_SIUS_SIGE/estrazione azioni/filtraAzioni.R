
actions<-read.table(file = "C:/discoD/progetti/Performance test/SIEP_SIUS_SIGE/estrai azioni/azioni.txt", stringsAsFactors = F)
actFilt<-sapply(actions, function(x){sub(".*Act","",x)})
write.table(actFilt,file = "./estrai azioni/azioni_7_SIEP_semiliberta_1.txt", row.names = F, col.names = F)