#Il file dfDistanze_2 e' stato prodotto dai programmi associaAna.R e calcolaScores.R. Il file dfDistanze_2.csv se necessario
#e' stato integrato a mano con i risultati ottenuti mediante Random Forest.

#Le associazioni elencate non sono comunque la soluzione finale del problema.
#
# - Un aserie potrebbe essere associata a piu' serie (a e b). Quale scegliere? Non per forza la distanza e' un criterio definitivo. La stazione a
# potrebbe essere quella piu' vicina(ad esempio) ma la stazione b (associata secondo criteri legati all'altezza, alla distanza di quota e alla somiglianza del nome)
# seppure piu' lontana (ma comunque nel raggio di 5km di distanza) potrebbe essere piu' lunga. Siccome il mio obiettivoe' allungare le serie, la serie
# b va preferita alla serie a

# Una serie hisCentral b associata alla serie della regione FVG potrebbe non coprire periodi diversi da quelli gi coperti dalla serie della regione FVG.
# In questo caso mi tengo la serie del FVG in quanto e' una serie che viene aggiornata e di cui dispongo i dati online e separatamente (come serie distinta) mi tengo la
# serie HisCentral (nel caso,difficile che accada, che le duestazioni sono coincidenti la cosa migliore sarebbe eliminare la serie di HisCentral)

#Questi esempi sopra ci dicono che: le associazioni trovate (in base a distanza, altezza e nome)vanno verificate (mediante grafico). Una volta 
#verificate allora mi tengo solo le associazioni utili

#Il programma genera un pdf con le serie associate. Guardare le associazioni e decidere--> nel file dfDistanze_2.csv creare una colonna "associare"
#con valore di default 0. Mettere 1 le righe corrispondenti ad associazioni valide. Far rigirare il programma. Questa volta verra creato un data.frame
#contenente le ssociazioni valide. I nomi delle stazioni sono quelle delle stazioni ultime, che allungano le serie hisCentral.
#

rm(list=objects())
library("tidyverse")
library("seplyr")

PARAM<-c("Tmax","Tmin")[2]

#Questo file (dfDistanze_2.csv) deriva dalle elaborazioni nella cartella "associa" integrata con i risultati ottenuti mediante random forest 
#In realta' i risultati ottenuto mediante RF ricalcano/confermano quelli in "associa". Solo in un caso RF ha dato un  risultato utile in piu'. Questo
#confronto tra RF e i risultati in "associa" va commentatomeglio su github e nella cartella "associa_usando_randomForest"
read_delim("dfDistanze_2.csv",delim=";",col_names = TRUE)->dfDistanze

#anagrafica hisCentral delle stazioni
read_delim("../../anagrafica/reg.friuli.info.csv",delim=";",col_names = TRUE)->ana

#A dfDistanze associamo  gli id delle stazioni hisCentral/stazioni FVG.
left_join(dfDistanze,ana[,c("SiteID","SiteCode","SiteName")],by=c("hc"="SiteName")) %>%
  rename(SiteId_hc=SiteID,SiteCode_hc=SiteCode)->dfDistanze

#anagrafica delle stazioni scaricate dalla regione FVG
read_delim("../../anagrafica/anagrafica_friuli_arpav.csv",delim=";",col_names = TRUE)->anaCF

#A dfDistanze associamo  i codici (codice) delle stazioni scaricate dal sito FVG.
left_join(dfDistanze,anaCF[,c("codice","stazione")],by=c("cf"="stazione")) %>%
  rename(codice_cf=codice)->dfDistanze

#Lettura dati della regione FVG (in modo inopportuno indicati con cf ovvero centro funzionale)
read_delim(glue::glue("../../data/{PARAM}_1991_2019.csv"),delim=";",col_names = TRUE,col_types = cols(.default = col_double()))->datiCF
names(datiCF)[4:ncol(datiCF)]<-Hmisc::capitalize(tolower(names(datiCF)[4:ncol(datiCF)]))

#Lettura dati degli Annali (dati HisCentral)
read_delim(glue::glue("../../data/{PARAM}_friuli.csv"),delim=",",col_names = TRUE,col_types = cols(.default = col_double()))->datiHC
names(datiHC)[4:ncol(datiHC)]<-Hmisc::capitalize(tolower(names(datiHC)[4:ncol(datiHC)]))

#trimSerie: elimina gli NA all'inizio e fine serie (non gli NA in mezzo a una serie di dati).
#L'output e' una serie con il primo dato un dato valido (non NA) e un ultimo dato valido (non NA)
trimSerie<-function(x){
  
  #Non posso fare semplicemente na.omit(x)-> perche' eliminerei anche i dati NA interni alla serie
  #che noi non vogliamo perdere come informazione
  na.omit(x)->temp
  
  #La prima riga di temp e' un dato valido
  temp[1,]->yymmddInizio
  #L'ultima riga di temp e' un dato valido
  temp[nrow(temp),]->yymmddFine
  
  which(x$yy==yymmddInizio$yy & x$mm==yymmddInizio$mm & x$dd==yymmddInizio$dd)->primaRigaDiDatiValidi
  which(x$yy==yymmddFine$yy & x$mm==yymmddFine$mm & x$dd==yymmddFine$dd)->ultimaRigaDiDatiValidi
  
  #serie priva di NA all'inizio e fine serie
  slice(x,primaRigaDiDatiValidi:ultimaRigaDiDatiValidi)
  
}#fine trimSerie


pdf(glue::glue("friuli{PARAM}_associazioni_dati_HC_dati_FVGregione.pdf"),12,12,onefile=TRUE)
par(mfrow=c(3,1))
purrr::map(1:nrow(dfDistanze),.f=function(riga){
  
  #nome stazione hc
  dfDistanze[riga,]$hc->hc

  ana[which(ana$SiteName==hc),]$SiteID->codice_hc
  
  tryCatch({
    datiHC[,c("yy","mm","dd",as.character(codice_hc))] 
  },error=function(e){ 
    NULL
  })->subDatiHC 
  
  #Le stazioni che abbiamo selezionato di HisCentral sono stazioni con dati quindi non e' possibile che la stazione sia elencata in anagrafica
  #ma non abbia dati
  if(is.null(subDatiHC)) browser() #che succede?
  
  
  trimSerie(x=subDatiHC)->subDatiHC
    
  #nome della stazione del FVG e il codice associato
  dfDistanze[riga,]$cf->cf
  dfDistanze[riga,]$codice_cf->codice_cf
  
  datiCF[,c("yy","mm","dd",cf)]->subDatiCF
 
  trimSerie(x=subDatiCF)->subDatiCF
  
  #Questo antijoin assume che la serie CF (Centro Funzionale/serie del Friuli Venezia Giulia sia una serie che continua la serie di HisCentral,
  #ovvero che la serie CF non sia una serie breve che cade all'interno del periodo coperto dalla serie di HisCentral. Piuttosto puo' succedere
  # il contrario: che la serie di HisCentral sia una serie breve che cade all'interno del periodo coperto dalla serie CF. In questo caso
  #l'antijoin restituisce un tibble con zero righe: subDatiCF coincide alloracon serieUnita. Nel caso in cui l'antijoin non restituisca un tibble
  #di zero righe significa che  la serie HC inizia prima della serie CF: adati corrisponde alla parte della serie HC che non si sovrappone alla serie CF)
  anti_join(subDatiHC,subDatiCF)->adati
  
  names(subDatiCF)<-c("yy","mm","dd",codice_hc)
  
  if(!nrow(adati)){
    subDatiCF->serieUnita
    glue::glue("Nessuna Associazione: solo serie {cf} ({codice_cf})")->titolo
  }else{
    #se non avessi aggiustato sopra i nomi bind_rows invece di unire le colonne delle due serie le avrebbe affiancate, due colonne
    #ciascuna col proprio nome
    bind_rows(adati,subDatiCF)->serieUnita
    glue::glue("Associazione: {hc} ({codice_hc}) - {cf} ({codice_cf})")->titolo
  }
  
  #serieUnita e' data da adati (la parte della serie hisCentral non coperta dalla serie della regione FVG) + il contributo della serie FVG.
  
  #serieUnita: facciamola iniziare dal primo gennaio del primo anno (annoI) e farla finire al 31 dicembre dell'ultimo anno (annoF)
  min(serieUnita$yy)->annoI
  max(serieUnita$yy)->annoF
  seq.Date(from=as.Date(paste0(annoI,"-01-01")),to=as.Date(paste0(annoF,"-12-31")),by="day")->calendario
  
  tibble(yymmdd=calendario) %>%
    separate(yymmdd,into=c("yy","mm","dd"),sep="-") %>%
    mutate(yy=as.double(yy),mm=as.double(mm),dd=as.double(dd))->dfCalendario
  
  #adesso serieFinale copre tutto il periodo che va da annoI a annoF
  left_join(dfCalendario,serieUnita)->serieFinale

  #per i grafici semplifichiamo il codice rinominando la stazione "finale"come"finale" invece di usare un codice numerico
  names(serieFinale)[4]<-"finale"
  
  #A ogni serie unita associamo anche i grafici della serie HC e dela serie CF
  
  #serie hc
  left_join(serieFinale,subDatiHC)->serieFinale
  names(serieFinale)[5]<-"hc"
  
  #serie cf
  left_join(serieFinale,subDatiCF)->serieFinale
  names(serieFinale)[6]<-"cf"
  
  
  plot(calendario,serieFinale$finale,type="l",main=titolo)
  
  plot(calendario,serieFinale$hc,type="l",col="red",main=hc)
  
  plot(calendario,serieFinale$cf,type="l",col="blue",main=cf)
  
  #se la colonna "associare" ha valore 1 vuoldire che l'associazione e' buona e va salvata in un file.
  #La colonna "associare" viene creata a mano: si fa girare questo programma una prima volta impostando la colonna
  #"associare" tutta a 0. Si vede il grafico, si valutano le associazioni e quelle buone vanno messe pari a 1 nella colonna "associare"
  #Si fa rigirare il programma e come output otteniamo un file di testo con le serie hisCentral+serie FVG unite
  
  
  
  if(dfDistanze[riga,]$associare==1){
    #la serie allungata prende il nome della serie ultima
    serieFinale %>%
      dplyr::select(yy,mm,dd,finale) %>%
      seplyr::rename_se(c(codice_cf:="finale"))
  }else{
    NULL
  }  
    
  
})->listaOut
dev.off()


purrr::compact(listaOut)->listaOut
if(length(listaOut)){
  purrr::reduce(listaOut,.f=full_join)->dfFinale
  dfFinale %>%arrange(yy,mm,dd)->dfFinale
  
  write_delim(dfFinale,glue::glue("{PARAM}_serieAllungate_hisCentral_regioneFVG.csv"),delim=";",col_names=TRUE)
  
}
