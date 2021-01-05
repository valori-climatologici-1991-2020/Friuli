#20 novembre 2020
#Programma per scaricare i dati giornalieri del Friuli Venezia Giulia
#
#Il programma e' stato scritto tenendo conto di alcune complicazioni che presenta il sito web.
#
# 1) Quando si passa da una stazione alla stazione successiva e' necessario rifare il refresh della pagina per resettare 
# l'anno al 2020, invece di partire dall'ultimo anno disponibile per la stazione precedente
#
# 2) Le condizioni di utilizzo a volte si resettano (unchecked) senza alcuno schema logico. Necessario quindi verificare se
# il pulsante e' checked o no.
#
# I problemi piu' grandi riguardano la selezione di anni mesi e delle stazioni dai menu a tendina. Individuato il tag option
# corrispondente all'anno (o mese o stazione) di interesse il normale click o clickElement non funziona, l'opzione non viene selezionata
#
# Soluzione: usare sendkeys
#
# Mesi: se mandiamo a sendkeys list("2","enter") (indipendentemente da quale option sia stata trovata mediante xpath) viene selezioanto
# il mese 2, se mandiamo list("3","enter") il mese 3...da due a 9 tutto semplice. Il problema e' per i mesi che iniziano per "1".
# Se mandiamo list("1","enter") sulla prima stazione trovata viene selezionato gennaio. Se poi ridiamo list("1",enter) vengono selezionati
# i mesi "10", "11","12" ....quindi sembrerebbe anche qui facile. Problema: passando alla seconda stazione la prima volta che si rida
# list("1","enter") viene selezionato "10" poi "11" e poi "12" (e di nuovo "10" sei si ripete il sendkeys con list("1","enter")).
#
# Soluzione per i mesi: list("t","enter"): il menu a tendina prevede anche la voce "tutti" (tutti i mesi). Passando la lettera "t" senza
# equivoco viene selenato "tutti" e cosi' si scaricano tutti i mesi.
#
# Anni: anche qui individuare il tag option con l'anno di interesse non serve a nulla, il click tramite RSelenium non funziona.
# Per selezionare gli anni tra il 2000 e il 2020 devo usare sendkeys con list("2","enter"). Il menu a tendina parte dall'anno 2020
# dopo ogni refresh delle pagina. Se voglio il 2019 devo inviare un sendkey(list("2","enter")), per selezionare il 2018 devo 
# mandare list("2","enter") due volte. Questa procedura e' implementata mediante un ciclo for
#
#
# Stazioni: anche qui il click dei menu a tendina non funziona. Prima di tutto devo mandare al menu a tendina la lettera con cui 
# inizia il nome della stazione "A", "B", "C" etc ect. Se ho una sola stazione che inizia per "A" mandero' solo una volta 
# sendkey(list("A","enter")) per poi entrare nei cicli degli anni e dei mesi.
#
# Per le stazioni che iniziano con "B" ho 6 scelte. Per selezionare la prima stazione che inizia per "B" mendero' sendkey(list("B","enter"))
# e poi iniziero' cicli cu anni e mesi
#
# La seconda stazione con "B" la seleziono mandando un secondo sendkey(list("B",enter")).
# Quando ho finito con la sesta stazione se rimando sendkey(list("B","enter")) ricomincerei con la prima stazione con la lettera B!
#
# Per evitare un loop infinito devo calcolare quante stazioni ho per ogni lettera dell'alfabeto (implementato mediante table(vettoreLetter))

rm(list=objects())
library("tidyverse")
library("RSelenium")
library("rvest")

urlFriuli<-"https://www.meteo.fvg.it/archivio.php?ln=&p=dati"

RSelenium::rsDriver(browser="firefox",check = FALSE,port=4569L)->mydrv
mydrv$client->myclient
myclient$navigate(urlFriuli)

read_delim("stazioni.txt",delim=";",col_names = FALSE)->listaStazioni
names(listaStazioni)<-"stazione"

vettoreLettere<-str_sub(listaStazioni$stazione,1,1)
table(vettoreLettere)->frequenzaLettere

LETTERA_STAZIONE_OLD<-NULL
MAX_NUMERO_CICLI<-0
CICLO<-0
#DATI_MANCANTI<-0

purrr::walk(listaStazioni$stazione,.f=function(staz){ 
  
  STAZIONE_GIA_ELABORATA<-FALSE
  
  #ogni volta che cambio stazione devo fare un refresh per ripartire dall'anno 2020 e non ripartire dall'ultimo anno elaborato
  #per la stazione precedente
  myclient$refresh()
  Sys.sleep(2)
  
  str_sub(staz,1,1)->LETTERA_STAZIONE 
  
  #se in un anno non ho dati comincio a incrementare DATI_MANCANTI. Se per tre anni di seguito la stazione non ha dati
  #smetto di fare cicli inutili e passo alla stazione successiva. Qui l'implementazione si basa sul fatto che gli anni
  #vengono scaricati a ritroso: dal 2019 indietro. Quindi se da un anno X andando indietro non trovo piu' dati significa che
  #i dati partono dall'anno X+1 fino ad arrivare a oggi.  
  DATI_MANCANTI<<-0
  
  if((LETTERA_STAZIONE_OLD!=LETTERA_STAZIONE) ||(is.null(LETTERA_STAZIONE_OLD))){ 
    LETTERA_STAZIONE_OLD<<-LETTERA_STAZIONE
    MAX_NUMERO_CICLI<<-as.integer(frequenzaLettere[LETTERA_STAZIONE])
    CICLO<<-0
  }
  
  #questo serve per contare il numero di cicli per le lettere dell'alfabeto  
  CICLO<<-CICLO+1

  #cerca il campo con la tendina dei nomi stazione  
  myclient$findElement(using = "id",value = "stazione")->pulsanteStazione
  

  #serve per passare alla prima,,alla seconda..alla terza stazione che inizia con la lettera "B" (ad esempio)  
  for(ii in 1:CICLO){ 
    print(glue::glue("click {ii}"))
    pulsanteStazione$findElement(using = "xpath","//*/option[@value='ARI@Ariis@syn@45.878300@13.090000@13']")$sendKeysToElement(list(LETTERA_STAZIONE,key = "enter"))    
    Sys.sleep(3)
  }

  myclient$findElement(using = "id",value = "giornalieri")->pulsanteGiornalieri
  pulsanteGiornalieri$clickElement()
  Sys.sleep(3)
  
  #questo serve per fare il ciclo sugli anni: quando e' stato scritto il programma
  #per scaricare i dati dal 2019 a ritroso, 1:29 (5 gennaio 2021)
  purrr::walk(1:1,.f=function(yy){ 
    
  if(STAZIONE_GIA_ELABORATA) {print("gia elaborata"); return()  }
    
  #se per tre anni non ho dati mi fermo. Ad esempio: parto dal 2019..scarico dati a ritroso fino al 2015. Poi dal 2014 per tre anni 
  #(2014, 2013,2012) non ho dati: mi fermo. La serie parte dal 2015 inutile fare cicli a vuoto    
  if(DATI_MANCANTI>3) return()    
  
  myclient$findElement(using = "id",value = "anno")->pulsanteAnno
  
  #Per selezionare i dati tra il 2019 e il 2000 devo inviare sendkey(list("2","enter")). Siccome il menu parte dal 2020
  #se mando un "enter" seleziono il 2019, se ne mando "2" ho il 2010 se ne mando 20 ho il 2000.
  #Per passare al 1999 devo inviare list("1","enter")  
  if(yy <=20){ 
    
    #if(yy==1) pulsanteAnno$findElement(using="xpath","//*/option[@value='2020']")$sendKeysToElement(list("2",key = "enter"))
    pulsanteAnno$findElement(using="xpath","//*/option[@value='2020']")$sendKeysToElement(list("2",key = "enter"))
    Sys.sleep(3)
  }else{ 
    pulsanteAnno$findElement(using="xpath","//*/option[@value='2020']")$sendKeysToElement(list("1",key = "enter"))
    Sys.sleep(3)
  }  
    
    myclient$findElement(using = "id",value = "mese")->pulsanteMese
    pulsanteMese$findElement(using="xpath","//*/option[@value='11']")$sendKeysToElement(list("1",key = "enter"))#seleziona mese 12
    Sys.sleep(3)
    
  #"t" -> tutti i mesi ..se dovessi selezionare un mese per volta..un casino per selezionare "gennaio"
  purrr::walk("t",.f=function(mm){  
    
    
    if(DATI_MANCANTI>3) return()
    
      as.character(mm)->mm
      str_sub(mm,1,1)->LETTERA_MESE

      myclient$findElement(using = "id",value = "mese")->pulsanteMese
      pulsanteMese$findElement(using="xpath","//*/option[@value='11']")$sendKeysToElement(list(LETTERA_MESE,key = "enter"))
      Sys.sleep(3)
      
      myclient$findElement(using = "id",value = "confnote")->pulsanteAccetta
      if(!pulsanteAccetta$isElementSelected()[[1]] ) pulsanteAccetta$clickElement()
      Sys.sleep(3)

      myclient$findElement(using = "id",value = "visualizza")$clickElement()
      #importante un momento di pausa altrimenti a volte fallisce la parte subito successiva del codice  
      Sys.sleep(2)
      
      
      myclient$getPageSource()[[1]] %>%
        read_html()->myhtml
      
      Sys.sleep(2)
      html_text(html_node(myhtml,xpath = "//*/h4"))->nomeStazione
      Sys.sleep(2)
      str_remove(nomeStazione,"Stazione: ")->nomeStazione
      Sys.sleep(2)
      html_text(html_nodes(myhtml,xpath = "//*/h5"))->nodih5

    #se non ho un tempo di attesa Sys.sleep(2) a volte myclient$getPageSource() non ha il tempo di acquisire la pagina sorgente
    #e fallisce la ricerca del titolo h5 dove stanno scritto nome stazione e anno<---------qui acquisisco anno e nome stazione che non
    #ho da nessuna altra parte 
      
      tryCatch({
        unlist(str_split(nodih5[[2]],pattern=" "))[1]->mese
        unlist(str_split(nodih5[[2]],pattern=" "))[2]->anno 
        
        list("mese"=mese,"anno"=anno)
      },error=function(e){
        NULL
      })->listaOut
      
      if(is.null(listaOut)) return()
      
      rvest::html_table(myhtml)->tabella
      
      tabella[[1]]->mydf

      if(nrow(mydf)){ 

	DATI_MANCANTI<<-0
        
        if(file.exists(glue::glue("{nomeStazione}_{anno}.csv"))){
          STAZIONE_GIA_ELABORATA<<-TRUE
          return()
        }
        
        mydf$yy<-as.integer(listaOut[["anno"]])
        #listaOut[["mese"]]->mese
        mydf$stazione<-nomeStazione
        write_delim(mydf %>% dplyr::select(stazione,yy,everything()),file=glue::glue("{nomeStazione}_{anno}.csv"),delim=";",col_names = TRUE)        
      }else{
       DATI_MANCANTI<<-DATI_MANCANTI+1 
      }  
        

      Sys.sleep(5)
      
    })#fine walk su mese  
      
  })#fine walk su anno 
  
})#fine walk da 1 a 53 
