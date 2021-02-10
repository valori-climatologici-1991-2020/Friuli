# Friuli

Dati per valori climatologici Friuli Venezia Giulia

## Dati HisCentral

I dati disponibili su HisCentral coprono il periodo 1912-2012. Questi dati coincidono con quelli disponibili presso il sito [web della regione del FVG](http://www.regione.fvg.it/rafvg/cms/RAFVG/ambiente-territorio/tutela-ambiente-gestione-risorse-naturali/FOGLIA205/#id4). I codici per interrogare questo database sono quelli della colonna SiteCode nell'anagrafica stazioni acquisita da HisCentral.

**I dati sopra descritti NON coincidono con i dati forniti da Meteo FVG (vedi sotto), anche per stazioni con lo stesso nome.**

## Dati online

Si tratta dei dati scaricabili da [Meteo FVG](https://www.meteo.fvg.it/archivio.php?ln=&p=dati) per il periodo 1991 a oggi. 
[Qui la lista dei dati elaborati](./docs_dati_online/scaricati.md) e [qui la mappa delle stazioni](https://github.com/valori-climatologici-1991-2020/Friuli/blob/main/selenium/mappa_stazioni/friuli_ana.geojson).

### Valori climatologici serie FVG

I valori climatologici temporanei sono descritti [qui](./docs_dati_online/climatologici_fvg.md)

### Serie associate HisCentral (HC) e serie del Friuli Venezia Giulia (CF).

CF sta per Centro Funzionale ma in realta' si tratta delle serie acquisite dal sito della Regione del Friuli Venezia Giulia.

Le serie sono state associate tenendo conto:
- della distanza (sono state associate stazioni che al piu' distano 5 kilometri)
- della quota (si ammette al massimo una differenza di quota di 25 metri)
- dei nomi delle stazioni (si e' considerata la distanza di Levenstein, distanza massimo di 30 (o 20?? rivedere codice)). Questa distanza puo' aiutare ad associare stazioni con lo stesso nome ma con piccole differenze tipo: S. invece di Santo. Una distanza pari a 30 pu associare anche stazioni con nomi completamente differenti.
- che le associazioni debbono essere uniche (nel senso che le serie di temperatura e precipitazione HisCentral sono associate alla stessa serie del FVG)

[Qui la tabella con le possibili associazioni](./docs_dati_online/associazione_HC_meteoFVG.md) tra le stazioni di HisCentral e quelle di Meteo FVG.

Un approccio alternativo di associare (che non tiene conto dei metadati) e' quello di utilizzare un modello Random Forests usando le serie HisCentral come predittori e le serie dell'FVG come valori target. 

Il vantaggio di questo approccio e' che:
- puo' fornire una conferma (basata sui dati) delle associazioni basate sui metadati
- non utilizza delle soglie di distanza (quota, altezza) rigidi (che invece ecluderebbe, ad esempio, una possibile associazione valida con una distanza di 5km e 1 metro!)

Lo svantaggio di questo approccio e' che:
- permette di testare le associazioni tra serie HisCentral e serie dell'FVG laddove i dati si sovrappongono su uno o piu' anni
- i predittori (ovvero le possibili serie FVG che spiegano la variabile target: la serie HisCentral) debbono essere sufficientemente numerosi 


## Dati flusso SCIA

Una sintesi delle serie di temperatura e precipitazione e' disponibile [qui]().
