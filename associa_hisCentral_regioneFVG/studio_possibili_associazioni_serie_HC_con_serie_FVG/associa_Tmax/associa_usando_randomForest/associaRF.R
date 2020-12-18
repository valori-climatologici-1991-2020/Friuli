#Verifico le associazioni trovate mediante la sola anagrafica utilizzando il Random Forest.
#Idea: testo una serie hisCentral (valore target) contro una serie di predittori (serie di temperatura della regione FVG). I predittori
#sono le possibili serie del Centro FVG identificate mediante associaAna.R (quindi identificate sui criteri di distanza, quota, nome stazione).

#Faccio girare per ogni serie HisCentral un modello RF(1000 alberi, facendo variare i parametri su una griglia di ricerca) e poi vedo l'importanza 
#dei predittori ovvero vedo la stazione FVG che assume la massima importanza per la variabile target. Ho cos trovato un'associazione.
#
#Problema: il modello ha senso se per ogni variabile target ho piu' predittori (stazioni FVG) possibili. A questo scopo il programma
#associaAna.R e' stato fatto girare aumentando il raggio di ricerca (20km), la tolleranza in quota (50 metri) e il costo di levenstein (50).
#Se per ogni stazione target ho almeno 2 stazioni FVG (2predittori) potrei far girare il modello.

#Altro problema: anche se ho almeno due stazioni/predittori non e' detto che abbiano dati nello stesso periodo in cui ha dati la serie HisCentral.
#Questo non mi permette di testare anche serie molto vicine e con nome simili se non ho un numero sufficiente di stazioni target.

#Utilit del programma:
# - per il Friuli in cui i periodi di sovrapposizione dei dati questo programma non fornisce molte piu' informazioni di quanto fornisca
# il programma associaAna.R fatto girare con parametri stringenti. Conferma alcune associazioni fattein base della sola anagrafica i cui valori
#di rmse e r2 non sono cosi' differenti tra molteplici associazioni

# - conferma alcune associazioni basate su anagrafica in cui i nomi delle stazioni hanno nomi completamente differenti 
#
# - se mediante anagrafica si fissa una soglia di tolleranza di 25 metri in quota, un'associazione corretta che differisce di 26metri non verra'
# trovata. Il RF non utilizzando l'anagrafica ma solo i dati delle serie permette di recuperare questi casi limite

rm(list=objects())
library("tidyverse")
library("ranger")
library("furrr")

plan(strategy = "multicore",workers=25)

PARAM<-c("Tmax","Tmin")[1]

read_delim("../../anagrafica/reg.friuli.info.csv",delim=";",col_names = TRUE)->ana

#dfDistanze_2.csv viene da associaAna.R e calcolaScores.R... gli scores (rmse, r2) che vengano calcolati o meno e' indifferente 
read_delim("dfDistanze_2.csv",delim=";",col_names = TRUE)->dfDistanze

#questi sono i deti del Centro Funzionale
read_delim(glue::glue("../../data/{PARAM}_1991_2019.csv"),delim=";",col_names = TRUE,col_types = cols(.default = col_double()))->datiCF

#questi sono i dati estratti dagli annali
read_delim(glue::glue("../../data/{PARAM}_friuli.csv"),delim=",",col_names = TRUE,col_types = cols(.default = col_double()))->datiHC


furrr::future_map(1:nrow(dfDistanze),.f=function(riga){
  
  dfDistanze[riga,]$hc->hc
  print(hc)

  ana[which(ana$SiteName==hc),]$SiteID->hcID 
  
  tryCatch({
    datiHC[,c("yy","mm","dd",as.character(hcID))] 
  },error=function(e){ 
    NULL
  })->subDatiHC 
  
  #in realta' l'anagrafica HisCentral e' stata ripulita quindi non dovrebbe mai verificarsi un errore sopra
  if(is.null(subDatiHC)){ print("salto"); return() }
  names(subDatiHC)[4]<-"hc"

  
  dfDistanze[riga,]$cf->cf
  datiCF[,c("yy","mm","dd",dfDistanze[dfDistanze$hc==hc,]$cf)]->subDatiCF

  
  left_join(subDatiCF,subDatiHC) %>%
    dplyr::select(-yy,-mm,-dd)%>% 
    filter(!is.na(hc))->ldati
  
  #ldati contiene i dati non NA nei periodi comuni per la serie HisCentral e la serie della regione FVG..se ci sono dati su periodi comuni
  na.omit(ldati)->ldati
  
  if(!nrow(ldati)){ print("salto"); return() }
  
  #Se ncol(ldati)== a 1 o 2 vuol dire che ho solo la variabile target o solo la variabile target e un predittore...salto alla prossima stazione
  if(ncol(ldati)<3){ print("salto"); return() }
  janitor::clean_names(ldati)->ldati

  ncol(ldati)-1->numPred  
  ceiling(numPred/3)->mtryStart
  
  expand.grid(
    mtry=seq(mtryStart,numPred,1),
    node_size=seq(30,120,15),
    sample_size=c(0.5,0.7,0.9),
    OOB_RMSE=0
  )->hyper_grid
  
  purrr::pmap(.l =list(mt=hyper_grid$mtry,ns=hyper_grid$node_size,ss=hyper_grid$sample_size),
              .f=function(mt,ns,ss){
                ranger(formula=hc~.,data=ldati,num.trees = 1000,importance = "impurity",splitrule = "variance",mtry=mt,min.node.size = ns,sample.fraction = ss,seed=123)
              })->ris
  
  purrr::map_dfr(ris,ranger::importance)->dfImportance
  dfImportance %>%
    mutate(rf=1:n()) %>%
    gather(key="stazione",value="importance",-rf)->dfImportance
  
  dfImportance %>%
    group_by(rf) %>%
    summarise(importance=max(importance)) %>%
    ungroup() %>%
    left_join(dfImportance)->finale
  
  table(finale$stazione)->tabella
  names(tabella)[which.max(tabella)]->stazioneAssociata

  tibble(hc=Hmisc::capitalize(tolower(hc)),cf=Hmisc::capitalize(tolower(stazioneAssociata)))
  
  
})->associazioni

reduce(associazioni,.f=bind_rows)->associazioni

left_join(associazioni,dfDistanze)->finale

write_delim(finale,"associazioni_possibili_RF.csv",delim=";",col_names = TRUE)

