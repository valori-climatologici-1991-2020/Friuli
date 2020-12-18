#25 novembre 2020

#Confronto fra i dati acquisiti dal FVG (sito web) e dati ricevuti (hisCentral/richiesta dati)
#
#Confrontiamo i dati scaricati dal sito della regione FVG (identificati come cf: centro funzionale, anche se il sito non e' quello del centro funzionale)
#con i dati acquisiti a suo tempo da HisCentral (integrati con i dati richiesti via mail/fax).
#
#Questo programma associa le stazioni sulla base della sola anagrafica, senza confrontare i dati delle serie:
#
# - distanze tra stazioni non superiori a 5km
# - distanza tra quote non superiore a 25 metri (come ECAD)
# - distanza tra stringhe (levenstein distance) non superiore a 30  <---

#Attenzione: nelle anagrafiche i nomi delle stazioni sono stati normalizzati mediante usando Hmisc::capitalize(tolower(nome)) 
#in modo di non avere nel computo della distanza tra stringhe il costo delle lettere maiuscole con le minuscole

#Il programma genera in output dfDistanze.csv. Questo file poi viene integrato con i valori di rmse, r2 mediante il programma calcolaScores.R

# Il programma calcolaScores.R utilizza dfDistanze.csv per generare dfDistanze_2.csv. Questo nuovo file contiene 
# i valori di RMSE (sui dati giornalieri), i valori di R2 (sui dati giornalieri e annuali). Questo programma genera
# un file pdf con gli scatterplot e le serie temporali associate. 
#
# Nota bene: non tutte le stazioni associate nel programma associaAna.R hanno dei dati quindi il fil dfDistanze_2.csv riporta NA
# laddove o uno dei due dataset non ha i dati per la stazione interessata o dove i dati nei periodi sovrapposti sono NA in una delle due stazioni
#

#Questi risultati vanno confrontati con il programma analogo che associa le stazioni mediante random forests.
rm(list=objects())
library("stringdist")
library("tidyverse")
library("sp")

#L'anagrafica originalenon aveva quota. Elevation_dem l'abbiamo estratta dal dem (raster)
read_delim("../../anagrafica/reg.friuli.info.csv",delim=";",col_names = TRUE) %>%
  rename(quotaHC=Elevation_dem)->anaHC

coordinates(anaHC)=~Longitude+Latitude
proj4string(anaHC)<-CRS("+init=epsg:4326")
spTransform(anaHC,CRSobj = CRS("+init=epsg:32632"))->anaHC

read_delim("../../anagrafica/anagrafica_friuli_arpav.csv",delim=";",col_names = TRUE)->anaCF

coordinates(anaCF)=~lon+lat
proj4string(anaCF)<-CRS("+init=epsg:4326")
spTransform(anaCF,CRSobj = CRS("+init=epsg:32632"))->anaCF

#Distanze tra stazioni HisCentral e Stazioni della regione FVG
spDists(anaHC,anaCF,longlat = FALSE)->distanze

as.data.frame(distanze)->dfDistanze
names(dfDistanze)<-anaCF$stazione
dfDistanze$hc<-anaHC$SiteName


dfDistanze %>%
  gather(key="cf",value="distanza",-hc)->dfDistanze

#Levenstein distance
stringdist(dfDistanze$hc,dfDistanze$cf,method="lv")->dfDistanze$lv

left_join(dfDistanze,anaCF@data[,c("stazione","quota")],by=c("cf"="stazione") )->dfDistanze

dfDistanze %>%
  rename(quotaCF=quota)->dfDistanze

left_join(dfDistanze,anaHC@data[,c("SiteName","quotaHC")],by=c("hc"="SiteName") )->dfDistanze

dfDistanze %>%
  mutate(quotaGap=abs(quotaHC-quotaCF))->dfDistanze

#Criteri di selezione: al piu' 5 km di distanza, 25 metri di differenza in quota e al piu' una distanza di Levenstein pari a 30
dfDistanze %>%
  filter(distanza<=5000 & lv<=30 & quotaGap<=25)->dfDistanze

write_delim(dfDistanze,"dfDistanze.csv",delim=";",col_names = TRUE)
