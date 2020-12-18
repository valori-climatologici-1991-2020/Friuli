#Questo programma parte da i risultati del programma associaAna.R
#
#Partendo dalle associazioni identificate mediante le anagrafiche, vengono calcolati i valori di rmse, r2 e il valore di rmse sulle medie annuali
#Questo programma inoltre genera anche unpdf coni grafici delle serie.

#Attenzione: non tutte le associazioni trovate mediante associaAna.R corrispondono a serie disponibili (l'anagrafica di hisCentral elenca anche stazioni
#di cui non abbiamo i dati)

#Attenzione: i valori di R2 sono tutti molto alti e anche i valori di rmse tra loro molto simili. Ovvero: i valori calcolati non sono molto utili
#per decidere (nel caso di associazioni multiple) quale sia la migliore (questo potrebbe dipendere anche dal fatto che spesso gli anni comuni sono pochi
#e quindi gli scores vengono calcolati su troppi pochi dati). Molto piu' utile valutare le associazioni trovate mediante i grafici generati in
# "grafici_associazione_serie"

#Output: dfDistanze_2.csv-> uguale a dfDistanze.csv ma con valori di rmse e r2. Questo file non elenca le serie HisCentral senza dati

rm(list=objects())
library("tidyverse")

PARAM<-c("Tmax","Tmin","Prec")[3]

read_delim("../../anagrafica/reg.friuli.info.csv",delim=";",col_names = TRUE)->ana

#generato da associaAna.R
read_delim("dfDistanze.csv",delim=";",col_names = TRUE)->dfDistanze

#Inizializzo colonne
dfDistanze$rmse<- -9999
dfDistanze$r2<- -9999
dfDistanze$rmse_annuale<- -9999

#questi sono i deti del Centro Funzionale
read_delim(glue::glue("../../data/{PARAM}_1991_2019.csv"),delim=";",col_names = TRUE,col_types = cols(.default = col_double()))->datiCF


#questi sono i dati estratti dagli annali
read_delim(glue::glue("../../data/{PARAM}_friuli.csv"),delim=",",col_names = TRUE,col_types = cols(.default = col_double()))->datiHC

pdf(glue::glue("friuli{PARAM}.pdf"),12,12,onefile=TRUE)
purrr::walk(1:nrow(dfDistanze),.f=function(riga){
  
  
  dfDistanze[riga,]$hc->hc

  ana[which(ana$SiteName==hc),]$SiteID->hcID 
  
  tryCatch({
    datiHC[,c("yy","mm","dd",as.character(hcID))] 
  },error=function(e){ 
    NULL
  })->subDatiHC 
  
  #L'associazione potrebbe corrispondere a una serie HisCentral di cui non ho dati
  if(is.null(subDatiHC)) return()
    
  dfDistanze[riga,]$cf->cf
  datiCF[,c("yy","mm","dd",cf)]->subDatiCF
  
  left_join(subDatiCF,subDatiHC)->ldati
  
  names(ldati)<-c("yy","mm","dd","cf","hc")
  ldati %>%
    filter(!is.na(hc) & !is.na(cf))->ldati
  
  nrow(ldati)->numeroRighe
  if(!numeroRighe) return()
  
  round(sqrt(mean( (ldati$hc-ldati$cf)^2 ,na.rm=TRUE)),1)->RMSE
  dfDistanze[riga,]$rmse<<-RMSE 
  
  lm(hc~cf+0,data=ldati)->lm.out
  summary(lm.out)->ris
  round(ris$r.squared,2)->R2
  dfDistanze[riga,]$r2<<-R2

  
  plot(ldati$hc,ldati$cf,main=paste0(hc," - ",cf, " - RMSE:",RMSE," - R2:",R2))
  abline(a=0,b=1,col="red")
  
  plot(ldati$hc,type="l",main=paste0(hc," - ",cf))
  points(x=1:numeroRighe,y=ldati$cf,type="l",col="red")
  

  ldati %>%
    dplyr::select(-dd) %>%
    mutate(yy=as.character(yy),mm=as.character(mm)) %>%
    group_by(yy,mm) %>%
    summarise_all(.funs=sum,na.rm=TRUE) %>%
    ungroup()->mensili
  
  plot(mensili$hc,type="l",main=paste0(hc," - ",cf))
  points(x=1:nrow(mensili),y=mensili$cf,type="l",col="red")
  
  ldati %>%
    dplyr::select(-dd,-mm) %>%
    mutate(yy=as.character(yy)) %>%
    group_by(yy) %>%
    summarise_all(.funs=sum,na.rm=TRUE) %>%
    ungroup()->annuali

  plot(annuali$hc,type="l",main=paste0(hc," - ",cf))
  points(x=1:nrow(annuali),y=annuali$cf,type="l",col="red")
  
  round(sqrt(mean( (annuali$hc-annuali$cf)^2 ,na.rm=TRUE)),1)->RMSE
  dfDistanze[riga,]$rmse_annuale<<-RMSE 

})
dev.off()

#dfDistanze_2.csv-> uguale a dfDistanze.csv ma con valori di rmse e r2. Questo file non elenca le serie HisCentral senza dati
write_delim(dfDistanze %>% filter(rmse>=0),"dfDistanze_2.csv",delim=";",col_names = TRUE)
