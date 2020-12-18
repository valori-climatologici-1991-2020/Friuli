Serie associate HisCentral (HC) e serie del Friuli Venezia Giulia (CF). Qui CF indica Centro Funzionale ma in realta' si tratta delle serie acquisite dal sito della Regione del Friuli Venezia Giulia.

Le serie sono state associate tenendo conto:
- della distanza (sono state associate stazioni che al piu' distano 5 kilometri)
- quota (si ammette al massimo una differenza di quota di 25 metri)
- i nomi delle stazioni (si e' considerata la distanza di Levenstein,distanza massimo di 30 (o 20?? rivedere codice))
- le associazioni sono uniche (nel senso che le serie di temperatura e precipitazione HisCentral sono associate alla stessa serie del FVG)

Un modo alternativo di procede potrebbe essere quello di utilizzare un modello Random Forests usando le serie HisCentral come predittori e le serie dell'FVG come valori target.

| SiteID | SiteName                         | SiteCode | Comments                      | Longitude          | Latitude           | cf                          | quotaCF | quotaHC           | quotaGap          | codice |
|--------|----------------------------------|----------|-------------------------------|--------------------|--------------------|-----------------------------|---------|-------------------|-------------------|--------|
| 8      | Sacile ponte lacchin             | A021     | Serie HisCentral +Regione FVG | 12.502             | 45.9509            | Brugnera                    | 22      | 22.2775802612305  | 0.277580261230469 | BRU    |
| 23     | Ponte racli                      | A240     | Serie HisCentral +Regione FVG | 12.7499            | 46.241199999999985 | Chievolis                   | 345     | 358.5740662       | 13.57406616       | CHI    |
| 36     | Pordenone localita' torre        | A301     | Serie HisCentral +Regione FVG | 12.672699999999999 | 45.9682            | Pordenone                   | 23      | 29.14749146       | 6.147491455       | POR    |
| 64     | Barcis ponte antoi               | A461     | Serie HisCentral +Regione FVG | 12.5749            | 46.1881            | Barcis                      | 468     | 470.3970337       | 2.397033691       | BAR    |
| 83     | Basaldella di vivaro             | A624     | Serie HisCentral +Regione FVG | 12.7906            | 46.08819999999999  | Vivaro                      | 142     | 141.309814453125  | 0.690185546875    | VIV    |
| 120    | Villa santina                    | C185     | Serie HisCentral +Regione FVG | 12.9115            | 46.41819999999999  | Enemonzo                    | 438     | 436.590850830078  | 1.40914916992188  | ENE    |
| 174    | Gemona canciane                  | C509     | Serie HisCentral +Regione FVG | 13.1363            | 46.26559999999999  | Gemona del friuli           | 184     | 189.9377594       | 5.937759399       | GEM    |
| 177    | Alesso                           | C551     | Serie HisCentral +Regione FVG | 13.055599999999998 | 46.30919999999999  | Bordano                     | 230     | 254.414566        | 24.41456604       | BOR    |
| 208    | San vito al tagliamento ospedale | D003     | Serie HisCentral +Regione FVG | 12.8542            | 45.9123            | San vito al tgl.            | 21      | 27.8097400665283  | 6.80974006652832  | SAN    |
| 236    | Rivarotta                        | E020     | Serie HisCentral +Regione FVG | 13.080999999999998 | 45.81929999999999  | Palazzolo dello stella      | 5       | 2.08233499526978  | 2.91766500473022  | PAL    |
| 243    | Codroipo                         | E202     | Serie HisCentral +Regione FVG | 12.9873            | 45.967000000000006 | Codroipo                    | 37      | 42.4894256591797  | 5.48942565917969  | COD    |
| 272    | Udine castello                   | G010     | Serie HisCentral +Regione FVG | 13.2367            | 46.06489999999999  | Udine s.o.                  | 91      | 114.8320236       | 23.83202362       | UDI    |
| 278    | Castions di strada               | G052     | Serie HisCentral +Regione FVG | 13.1941            | 45.9052            | Talmassons                  | 16      | 20.1417102813721  | 4.14171028137207  | TAL    |
| 307    | Cervignano                       | J212     | Serie HisCentral +Regione FVG | 13.3412            | 45.81629999999999  | Cervignano del friuli       | 8       | 3.27102828025818  | 4.72897171974182  | CER    |
| 308    | Risano case moschioni            | J400     | Serie HisCentral +Regione FVG | 13.2514            | 45.98469999999999  | Lauzacco                    | 60      | 62.5455131530762  | 2.54551315307617  | LAU    |
| 322    | Lignano sabbiadoro               | M002     | Serie HisCentral +Regione FVG | 13.1212            | 45.686499999999995 | Lignano sabbiadoro          | 7       | 2.316202879       | 4.683797121       | LIG    |
| 328    | Grado sede g.i.t.                | M051     | Serie HisCentral +Regione FVG | 13.3947            | 45.6765            | Grado                       | 5       | 0.421869248       | 4.578130752       | GRD    |
| 337    | Gradisca d'isonzo                | N026     | Serie HisCentral +Regione FVG | 13.4971            | 45.884499999999996 | Gradisca d'is.              | 29      | 28.204963684082   | 0.795036315917969 | GRA    |
| 348    | Fossalon bonifica vittoria       | N045     | Serie HisCentral +Regione FVG | 13.4966            | 45.7341            | Fossalon                    | 0       | -1                | 1                 | FOS    |
| 368    | Povoletto                        | N302     | Serie HisCentral +Regione FVG | 13.309000000000001 | 46.122899999999994 | Faedis                      | 158     | 131.512878417969  | 26.4871215820312  | FAE    |
| 375    | Cerneglons                       | N311     | Serie HisCentral +Regione FVG | 13.318100000000001 | 46.0558            | Pradamano                   | 91      | 91.3938293457031  | 0.393829345703125 | PRD    |
| 386    | Azzida                           | N410     | Serie HisCentral +Regione FVG | 13.4947            | 46.11829999999999  | San pietro al natisone      | 160     | 176.2376862       | 16.23768616       | SPN    |
| 389    | Cividale istituto agrario        | N450     | Serie HisCentral +Regione FVG | 13.418200000000002 | 46.09669999999999  | Cividale del friuli         | 127     | 132.3032379       | 5.303237915       | CIV    |
| 395    | Cormons                          | N603     | Serie HisCentral +Regione FVG | 13.469299999999999 | 45.96              | Capriva del friuli          | 85      | 79.207275390625   | 5.792724609375    | CAP    |
| 410    | Alberoni idrovora sacchetti      | P002     | Serie HisCentral +Regione FVG | 13.5131            | 45.7779            | Monfalcone                  | 0       | -0.00922922976315 | 0.00922922976315  | MNF    |
| 415    | Borgo grotta gigante             | R102     | Serie HisCentral +Regione FVG | 13.7644            | 45.7094            | Borgo grotta gigante        | 275     | 274.7296448       | 0.270355225       | BGG    |
| 419    | Trieste istituto nautico         | S002     | Serie HisCentral +Regione FVG | 13.764599999999998 | 45.6475            | Trieste molo f.lli bandiera | 1       | 7.493386745       | 6.493386745       | TRI    |
| 426    | Tarvisio                         | V002     | Serie HisCentral +Regione FVG | 13.570099999999998 | 46.506299999999996 | Tarvisio                    | 794     | 788.6018677       | 5.398132324       | TAR    |
