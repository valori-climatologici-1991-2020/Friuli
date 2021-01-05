rm(list=objects())
library("tidyverse")

#annoI e annoF compaiono nel file di output
annoI<-2020
annoF<-2020

PARAM<-c("Tmax","Tmin","Prec")[3]

if(PARAM=="Tmin"){
  "Temp. min"->MYMATCH
}else if(PARAM=="Tmax"){
  "Temp. max"->MYMATCH
}else if(PARAM=="Prec"){
  "Pioggia"->MYMATCH
}

list.files(pattern="^.+csv$")->ffile
unique(str_remove(ffile,"_(1|2)[0-9]{3}\\.csv"))->nomiStazioni

#Devo togliere a Sappada le parentesi, altrimenti probleminell'espressione regolare
str_remove(nomiStazioni,"\\(.+\\)")->nomiStazioni

#Quanto segue ha senso solo se c e' Grado e Grado a mare, Monte Lussari e Monte Lussari sm
if(1==0){
    #Devo togliere Grado-mare perche' Grado-mare viene preso gi dall'espressione regolare con Grado.
    nomiStazioni[-grep("mare",nomiStazioni)]->nomiStazioni
    #Devo togliere "Monte Lussari sm" perche' "Monte Lussari sm" viene preso gia dall'espressione regolare con "Monte Lussari".
    nomiStazioni[-grep("Monte Lussari sm",nomiStazioni)]->nomiStazioni
}

purrr::map(nomiStazioni,.f=function(nomeStazione){
  
  
  list.files(pattern=paste0("^",nomeStazione,".+\\.csv$"))->ffile

  purrr::map_dfr(ffile,.f=function(nomeFile){
    
    read_delim(nomeFile,delim=";",col_names=TRUE,col_types = cols(.default=col_double(),stazione=col_character()))
    
  })->dati

  tryCatch({
    
    dati %>%
      dplyr::select(stazione,yy,mese,matches("^giorn"),matches(MYMATCH))
    
  },error=function(e){
    
    NULL
    
  })->dati
  
  if(is.null(dati)) browser()

  names(dati)<-c("stazione","yy","mm","dd","value")
  
  if(!nrow(dati)) return()

  dati[!duplicated(dati[,c("stazione","yy","mm","dd")]),]->dati
  #if(any(grepl("mare",dati$stazione))) browser()
  
  if(any(is.na(dati$stazione))) browser()
  
  dati
  
})->listaOut

purrr::compact(listaOut)->listaOut
purrr::reduce(listaOut,.f=bind_rows)->mydf


mydf %>%
  spread(key=stazione,value=value) %>%
  arrange(yy,mm,dd) %>%
  filter(yy<=annoF)->finale

length(seq.Date(from=as.Date(glue::glue("{annoI}-01-01")),to=as.Date(glue::glue("{annoF}-12-31")),by="day"))->numeroGiorni

stopifnot(nrow(finale)==numeroGiorni)
write_delim(finale,glue::glue("{PARAM}_{annoI}_{annoF}.csv"),delim=";",col_names=TRUE)