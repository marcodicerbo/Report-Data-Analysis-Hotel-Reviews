# Report-Data-Analysis-Hotel-Reviews
Analisi recensioni Booking.com – Hotel di lusso in Europa (2015–2017)
1. Descrizione del progetto
Questo repository contiene un progetto di data analysis end to end su un dataset reale di recensioni Booking.com per circa 515.000 recensioni relative a 1.493 hotel di lusso in Europa, nel periodo 2015–2017. 
L’obiettivo del progetto è:
•	importare, pulire e trasformare un dataset di grandi dimensioni con Python/Pandas; 
•	progettare e popolare uno schema relazionale SQL con chiavi primarie e esterne; 
•	sviluppare query SQL per rispondere a domande di business (trend temporali, nazionalità dei recensori, performance di hotel e città, lunghezza delle recensioni); 
•	riprodurre e approfondire le analisi in Pandas; 
•	produrre visualizzazioni (Matplotlib/Plotly) da integrare in un report finale in PDF rivolto a un contesto aziendale e a figure come i Revenue Manager. 
Questo README spiega come è stato svolto il lavoro e fornisce le istruzioni per replicare l’analisi.
________________________________________
2. Dataset
Il dataset originale è scaricabile al link https://www.kaggle.com/ datasets/jiashenliu/515k-hotel-reviews-data-in-europe/data. I dati sono stati estratti da Booking.com che ne è proprietario. Per eccessive dimensioni di alcuni files, si condivide il link google drive della cartella in cui sono contenuti i dataset e i dati utilizzati per l’analisi: https://drive.google.com/drive/folders/1ML0zo-pJ9qK-ApG31Uoo8o_ZMk_8gU0v?usp=sharing 

In particolare, sono stati inclusi: 
1.	Il file originale: Hotel_Reviews.csv;
2.	Il file pulito: hotel_reviews_clean.csv;
3.	I dataset suddivisi per la creazione delle tabelle in sql: hotels.csv, hotel_stats.csv, reviewers.csv e reviews.csv;
4.	Il file sql contenente tutti i dati utilizzati per popolare il database sql: INSERT_DATA.sql
Descrizione dataframe:
•	Nome file originale: Hotel_Reviews.csv (nome esatto eventualmente da adattare al file scaricato).
•	Fonte: dataset pubblico Kaggle “515k Hotel Reviews Data in Europe”. 
•	Contenuto principale: 
•	informazioni sull’hotel (nome, indirizzo, città, latitudine, longitudine);
•	data della recensione e punteggi (AverageScore, Reviewer_Score);
•	nazionalità del recensore;
•	testo della recensione positiva e negativa;
•	conteggio parole positive/negative;
•	numero di recensioni precedenti del recensore;
•	numero totale di recensioni ricevute dall’hotel;
•	durata tra data recensione e data estrazione (days_since_review).
________________________________________
3. Workflow di analisi 
3.1 Esplorazione e pulizia dati – 01_EDA_CLEANING.ipynb
In questo notebook si svolgono tutte le operazioni di preparazione e pulizia dei dati. 
Passi principali:
1.	Caricamento del dataset grezzo
•	Leggere DATA/Hotel_Reviews.csv in un DataFrame Pandas (pd.read_csv). 
•	Verificare dimensioni e tipi (df.shape, df.info()).
2.	Esplorazione iniziale
•	Analizzare la distribuzione dei punteggi (Reviewer_Score, Average_Score).
•	Identificare valori mancanti e anomalie. 
3.	Pulizia di base
•	Gestire i missing values secondo criteri coerenti (es. drop di righe non informative, imputazione semplice dove necessario).
•	Convertire le colonne temporali in datetime (es. Review_Date), ed estrarre anno, mese e una colonna combinata anno-mese (ReviewYear, ReviewMonth, ReviewYearMonth). 
•	Rimuovere eventuali duplicati esatti. 
4.	Creazione di variabili derivate
•	ReviewLength: numero di caratteri o parole della recensione (positiva + negativa).
•	Eventuali normalizzazioni o codifiche di supporto (es. trasformazione stringhe, categorie, ecc.).
5.	Esportazione del dataset pulito
•	Salvare il DataFrame pulito in DATA/hotel_reviews_clean.csv tramite df.to_csv(..., index=False).
•	Questo file viene successivamente utilizzato sia per il caricamento nel database SQL sia per le analisi con Pandas. 
3.2 Creazione schema SQL – sql/CREATE_TABLES.sql
In questa fase si progetta e crea lo schema relazionale nel DB prescelto.
1.	Definire le tabelle principali:
•	hotels (identificativo hotel, nome, indirizzo, città, coordinate, ecc.);
•	reviews (id recensione, id hotel, data, punteggi, testi, lunghezze, conteggi parole, ecc.);
•	reviewers;
•	hotel_stats;
2.	Definire chiavi primarie e foreign key:
3.	Eseguire lo script CREATE_TABLES.sql nel DB per creare la struttura.
3.3 Popolamento del database – sql/INSERT_DATA.sql
Una volta creato lo schema, si procede al caricamento dei dati puliti nel database: 
1.	Importare hotel_reviews_clean.csv 
2.	Eseguire le istruzioni in INSERT_DATA.sql per:
•	popolare la tabella hotels con le informazioni univoche sugli hotel;
•	popolare la tabella reviews con una riga per ciascuna recensione, collegata all’hotel di riferimento;
•	popolare le altre tabelle.
3.	Verificare i conteggi:
•	numero di righe in reviews vs righe del dataset pulito;
•	coerenza dei join (es. SELECT COUNT(*) FROM reviews JOIN hotels ...). 
3.4 Analisi con SQL – sql/ANALYSIS_QUERIES.sql
In questo file sono raccolte le query SQL.
Esempi di gruppi di query:
1.	Recensioni nel tempo
•	Andamento delle recensioni per mese/anno.
•	Identificazione dell’hotel con il maggior numero di recensioni in un certo periodo.
2.	Nazionalità dei recensori
•	Top 10 nazionalità per numero di recensioni.
•	Confronto dello score medio dei recensori UK vs altre nazionalità. 
3.	Hotel e performance
•	Hotel con maggiore Average_Score.
•	Analisi del gap tra Reviewer_Score (singolo utente) e Average_Score (media hotel). 
4.	Geografia
•	Distribuzione delle recensioni per città.
•	Score medio per nazione o città.
5.	Lunghezza delle recensioni
•	Distribuzione di ReviewLength per categorie di score.
•	Valutazione della relazione fra lunghezza recensione e Reviewer_Score.
3.5 Analisi con Pandas e generazione grafici – 02_ANALYSIS_PANDAS_PLOTS.ipynb
In questo notebook si riproducono e approfondiscono le analisi viste in SQL, questa volta con Pandas e librerie grafiche. 
Passi principali:
1.	Import dati
2.	Riproduzione analisi SQL
•	Gruppi mensili per numero di recensioni.
•	Ranking nazionalità per numero di recensioni e score medio.
•	Distribuzione delle recensioni per città.
3.	Analisi aggiuntive
•	Feature engineering su variabili testuali (lunghezza recensione, word counts, days_since_review).
•	Confronto dei risultati ottenuti con SQL e con Pandas per coerenza. 
4.	Creazione dei grafici 
•	Line plot di recensioni per mese e per anno.
•	Bar chart Top 10 nazionalità per numero di recensioni.
•	Bar chart Top città per numero di recensioni.
•	Box plot della distribuzione di Reviewer_Score per le principali nazionalità.
•	Istogramma della lunghezza delle recensioni per categorie di score.
•	Violin plot per visualizzare la relazione fra lunghezza recensione e punteggio.
•	Bar chart dello score medio per città.
•	Heatmap delle correlazioni fra variabili numeriche (score, conteggi parole, days_since_review).
5.	Esportazione dei grafici
•	Salvare ogni grafico in formato .png (es. in una cartella plots/), per poterli poi inserire nel report finale in PDF. 
________________________________________
4. Report finale
Il report finale (report/FinalReport.pdf)  viene redatto a partire da:
•	gli insight e le tabelle ottenute tramite SQL e Pandas;
•	i grafici salvati dal notebook 02_ANALYSIS_PANDAS_PLOTS.ipynb.
La struttura del report segue lo schema indicato: 
1.	Introduzione: descrizione del dataset (Booking.com, 515K recensioni, 1.493 hotel in Europa, 2015–2017).
2.	Metodologia: pipeline Pulizia → SQL → Pandas → Visualizzazioni.
3.	Risultati principali: trend temporali, profilo nazionalità, performance città/hotel, correlazioni score–lunghezza.
4.	Conclusioni: insight per il business e per i Revenue Manager.
________________________________________
5. Come replicare l’analisi
Per replicare l’analisi:
1.	Clonare il repository e installare le dipendenze.
2.	Scaricare il dataset Kaggle, copiarlo in DATA/ e aggiornare eventualmente i percorsi nei notebook. 
3.	Eseguire 01_EDA_CLEANING.ipynb per generare il file pulito hotel_reviews_clean.csv.
4.	Creare il database ed eseguire sql/CREATE_TABLES.sql per creare lo schema.
5.	Eseguire sql/INSERT_DATA.sql per popolare il database.
6.	Eseguire le query in sql/ANALYSIS_QUERIES.sql per ottenere le aggregazioni e i risultati intermedi.
7.	Eseguire 02_ANALYSIS_PANDAS_PLOTS.ipynb per riprodurre e approfondire le analisi e salvare tutti i grafici richiesti.

