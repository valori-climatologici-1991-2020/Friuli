rm(list=objects())
library("tidyverse")

PARAM<-"Tmin"

list.files(pattern="^.+csv$")->ffile
unique(str_remove(ffile,"_(1|2)[0-9]{3}\\.csv"))->nomiStazioni

#Devo togliere a Sappada le parentesi, altrimenti probleminell'espressione regolare
str_remove(nomiStazioni,"\\(.+\\)")->nomiStazioni
#Devo togliere Grado-mare perche' Grado-mare viene preso gi dall'espressione regolare con Grado.
nomiStazioni[-grep("mare",nomiStazioni)]->nomiStazioni
#Devo togliere "Monte Lussari sm" perche' "Monte Lussari sm" viene preso gia dall'espressione regolare con "Monte Lussari".
nomiStazioni[-grep("Monte Lussari sm",nomiStazioni)]->nomiStazioni


purrr::map(nomiStazioni,.f=function(nomeStazione){
  
  
  list.files(pattern=paste0("^",nomeStazione,".+\\.csv$"))->ffile

  purrr::map_dfr(ffile,.f=function(nomeFile){
    
    read_delim(nomeFile,delim=";",col_names=TRUE,col_types = cols(.default=col_double(),stazione=col_character()))
    
  })->dati

  tryCatch({
    
    dati %>%
      dplyr::select(stazione,yy,mese,matches("^giorn"),matches("Temp. min°C"))
    
  },error=function(e){
    
    NULL
    
  })->dati
  
  if(is.null(dati)) browser()

  names(dati)<-c("stazione","yy","mm","dd","value")
  
  if(!nrow(dati)) return()

  dati[!duplicated(dati[,c("stazione","yy","mm","dd")]),]->dati
  #if(any(grepl("mare",dati$stazione))) browser()
  dati
  
})->listaOut

purrr::compact(listaOut)->listaOut
purrr::reduce(listaOut,.f=bind_rows)->mydf


mydf %>%
  spread(key=stazione,value=value) %>%
  arrange(yy,mm,dd) %>%
  filter(yy<=2019)->finale

length(seq.Date(from=as.Date("1991-01-01"),to=as.Date("2019-12-31"),by="day"))->numeroGiorni

stopifnot(nrow(finale)==numeroGiorni)
write_delim(finale,glue::glue("{PARAM}_1991_2019.csv"),delim=";",col_names=TRUE)