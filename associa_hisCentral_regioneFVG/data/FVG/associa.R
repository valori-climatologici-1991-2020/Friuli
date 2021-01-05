rm(list=objects())
library("tidyverse")

annoI<-2020
annoF<-2020

PARAMETRO<-c("Prec")

read_delim("reg.sito_web_fvg.info.csv",delim=";",col_names = TRUE)->ana
read_delim(glue::glue("{PARAMETRO}_{annoI}_{annoF}.csv"),delim=";",col_names = TRUE,
           col_types = cols(yy=col_integer(),mm=col_integer(),dd=col_integer(),.default = col_double()))->dati

names(dati)->NOMI
Hmisc::capitalize(tolower(str_trim(NOMI,side="both")))->NOMI
ana$SiteID[match(NOMI,ana$SiteName)]->NUOVI_NOMI
print(length(NOMI)-3)
print(length(NUOVI_NOMI[!is.na(NUOVI_NOMI)]))

names(dati)[4:ncol(dati)]<-NUOVI_NOMI[!is.na(NUOVI_NOMI)]
write_delim(dati,glue::glue("{PARAMETRO}_{annoI}_{annoF}_SiteID.csv"),delim=";",col_names = TRUE)
           

