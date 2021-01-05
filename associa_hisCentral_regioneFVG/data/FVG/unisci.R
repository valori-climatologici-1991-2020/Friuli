rm(list=objects())
library("tidyverse")

PARAM<-c("Prec","Tmax","Tmin")[3]
TIPI<-cols(yy=col_integer(),mm=col_integer(),dd=col_integer(),.default = col_double())

list.files(pattern=glue::glue("^{PARAM}.+csv$"))->ffile
stopifnot(length(ffile)==2)

purrr::partial(.f=read_delim,delim=";",col_names=TRUE,col_types=TIPI)->leggi

purrr::map_dfr(ffile,.f=~(leggi(.)))->finale

print(skimr::skim(finale[,c("yy","mm","dd")]))

if(any(is.na(finale$yy))) browser()
if(any(is.na(finale$mm))) browser()
if(any(is.na(finale$dd))) browser()

min(finale$yy)->annoI
max(finale$yy)->annoF

tibble(yymmdd=seq.Date(from=as.Date(glue::glue("{annoI}-01-01")),to=as.Date(glue::glue("{annoF}-12-31")),by="day")) %>%
  separate(yymmdd,into=c("yy","mm","dd"),sep="-") %>%
  mutate(yy=as.integer(yy),mm=as.integer(mm),dd=as.integer(dd))->calendario

left_join(calendario,finale)->finale

write_delim( finale %>% arrange(yy,mm,dd),glue::glue("{PARAM}_unione.csv"),delim=";",col_names = TRUE)
