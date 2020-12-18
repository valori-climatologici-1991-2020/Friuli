rm(list=objects())
library("tidyverse")

PARAMETRO<-c("Prec")

read_delim("reg.sito_web_fvg.info.csv",delim=";",col_names = TRUE)->ana
read_delim(glue::glue("{PARAMETRO}_1991_2019.csv"),delim=";",col_names = TRUE,
           col_types = cols(yy=col_integer(),mm=col_integer(),dd=col_integer(),.default = col_double()))->dati

names(dati)->NOMI
ana$SiteID[match(names(dati),ana$SiteName)]->NUOVI_NOMI
print(length(NOMI)-3)
print(length(NUOVI_NOMI[!is.na(NUOVI_NOMI)]))

names(dati)[4:ncol(dati)]<-NUOVI_NOMI[!is.na(NUOVI_NOMI)]
write_delim(dati,glue::glue("{PARAMETRO}_1991_2019_SiteID.csv"),delim=";",col_names = TRUE)
           

