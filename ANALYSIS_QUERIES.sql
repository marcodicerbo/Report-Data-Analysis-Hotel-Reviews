/*Questo file contiene il codice di input delle analisi condotte su mysql.*/

/*Controllo conteggi righe*/
SELECT 'hotels' AS table_name, COUNT(*) AS row_count FROM hotels
UNION ALL
SELECT 'reviewers' AS table_name, COUNT(*) AS row_count FROM reviewers
UNION ALL
SELECT 'reviews' AS table_name, COUNT(*) AS row_count FROM reviews
UNION ALL
SELECT 'hotel_stats' AS table_name, COUNT(*) AS row_count FROM hotel_stats;

/*Controllo join hotel reviews*/
SELECT
    h.hotel_id,
    h.hotel_name,
    COUNT(r.review_id) AS num_reviews
FROM hotels AS  h
LEFT JOIN reviews AS  r
    ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_id, h.hotel_name
ORDER BY num_reviews DESC;

/*Verifico distribuzione score per nazionalità*/
SELECT re.reviewer_nationality,
COUNT(*) AS num_reviews, 
ROUND(AVG(rv.reviewer_score), 2) AS avg_reviewer_score /*utilizzo round per arrotondare la media a due decimali*/ 
FROM reviews rv 
JOIN reviewers re ON rv.reviewer_id = re.reviewer_id 
GROUP BY re.reviewer_nationality 
ORDER BY num_reviews DESC, avg_reviewer_score DESC;

/*Query SQL
1. Recensioni nel Tempo*/
/*Andamento recensioni mese e anno*/
SELECT
    review_year,
    COUNT(*) AS num_reviews
FROM reviews
GROUP BY review_year
ORDER BY review_year;

SELECT
    review_yearmonth,
    COUNT(*) AS num_reviews
FROM reviews
GROUP BY review_yearmonth
ORDER BY review_yearmonth;

/*Hotel con picco recensioni*/

SELECT
    h.hotel_name,
    s.total_number_of_reviews
FROM hotels h
JOIN hotel_stats s
    ON h.hotel_id = s.hotel_id
ORDER BY s.total_number_of_reviews DESC
LIMIT 1; -- Hotel Da Vinci con 16670 recensioni

/*2. Nazionalità Recensori*/
/*Top 10 nazionalità per numero recensioni e score medio*/
SELECT
    reviewer_nationality,
    COUNT(*) AS num_reviews,
    ROUND(AVG(reviewer_score), 2) AS avg_reviewer_score
FROM reviewers
JOIN reviews
    ON reviewers.reviewer_id = reviews.reviewer_id
GROUP BY reviewer_nationality
ORDER BY num_reviews DESC, avg_reviewer_score DESC
LIMIT 10;

/*% contributo top 10 nazionalità al totale delle recensioni*/
SELECT
    t.reviewer_nationality,
    t.num_reviews,
    ROUND(100.0 * t.num_reviews / total_reviews.total, 2) AS pct_total_reviews
FROM (
    SELECT
        re.reviewer_nationality,
        COUNT(*) AS num_reviews
    FROM reviews rv
    JOIN reviewers re
        ON rv.reviewer_id = re.reviewer_id
    GROUP BY re.reviewer_nationality
    ORDER BY num_reviews DESC
    LIMIT 10
) t
CROSS JOIN ( /*Ho usato un CROSS JOIN per affiancare a ciascuna nazionalità il totale complessivo delle recensioni e calcolare così il contributo percentuale sul totale*/
    SELECT COUNT(*) AS total
    FROM reviews
) total_reviews
ORDER BY t.num_reviews DESC;

/* Confronto score medio UK vs altri*/
SELECT
    nationality_group,
    COUNT(*) AS num_reviews,
    ROUND(AVG(reviewer_score), 2) AS avg_reviewer_score
FROM (
    SELECT
        CASE
            WHEN UPPER(TRIM(reviewer_nationality)) = 'UNITED KINGDOM' THEN 'UK'
            ELSE 'Non-UK'
        END AS nationality_group,
        reviewer_score
    FROM reviews rv
    JOIN reviewers re
        ON rv.reviewer_id = re.reviewer_id
) x
GROUP BY nationality_group
ORDER BY nationality_group;

/*3. Hotel e Performance
Hotel con maggior Average_Score e numero recensioni*/
SELECT
    h.hotel_id,
    h.hotel_name,
    ROUND(AVG(rv.reviewer_score), 2) AS average_score,
    COUNT(*) AS num_reviews
FROM reviews rv
JOIN hotels h
    ON rv.hotel_id = h.hotel_id
GROUP BY h.hotel_id, h.hotel_name
ORDER BY average_score DESC, num_reviews DESC
LIMIT 1;

/*Analisi gap tra Reviewer Score e Average Score*/
SELECT
    h.hotel_id,
    h.hotel_name,
    ROUND(AVG(rv.reviewer_score), 2) AS avg_reviewer_score,
    hs.average_score,
    ROUND(AVG(rv.reviewer_score) - hs.average_score, 2) AS score_gap,
    COUNT(*) AS num_reviews
FROM reviews rv
JOIN hotels h
    ON rv.hotel_id = h.hotel_id
JOIN hotel_stats hs
    ON rv.hotel_id = hs.hotel_id
GROUP BY h.hotel_id, h.hotel_name, hs.average_score
ORDER BY ABS(AVG(rv.reviewer_score) - hs.average_score) DESC, num_reviews DESC;

/*4. Geografia
Distribuzione recensioni per città*/
SELECT -- mostra sia il numero assoluto sia il peso percentuale di ogni città sul totale delle recensioni
    h.hotel_city,
    SUM(s.total_number_of_reviews) AS total_reviews,
    ROUND(
        SUM(s.total_number_of_reviews) * 100.0 /
        (SELECT SUM(total_number_of_reviews) FROM hotel_stats),
        2
    ) AS pct_reviews
FROM hotels h
JOIN hotel_stats s
    ON h.hotel_id = s.hotel_id
WHERE h.hotel_city IS NOT NULL
  AND h.hotel_city <> ''
GROUP BY h.hotel_city
ORDER BY total_reviews DESC; 

/*Score medio per nazione*/
SELECT -- calcola la media degli average_score degli hotel per ogni nazione
    h.nation,
    ROUND(AVG(s.average_score), 2) AS avg_score,
    COUNT(*) AS num_hotels
FROM hotels h
JOIN hotel_stats s
    ON h.hotel_id = s.hotel_id
WHERE h.nation IS NOT NULL
  AND h.nation <> ''
GROUP BY h.nation
ORDER BY avg_score DESC;

/*Score medio per città*/
SELECT -- calcola la media degli average_score degli hotel per ogni città 
    h.hotel_city,
    ROUND(AVG(s.average_score), 2) AS avg_score,
    COUNT(*) AS num_hotels
FROM hotels h
JOIN hotel_stats s
    ON h.hotel_id = s.hotel_id
WHERE h.hotel_city IS NOT NULL
  AND h.hotel_city <> ''
GROUP BY h.hotel_city
ORDER BY avg_score DESC;

/*5. Lunghezza Recensioni
Distribuzione Review_Length per categoria score*/
SELECT -- distribuzione raggruppando per il valore dello score
    r.reviewer_score,
    COUNT(*) AS num_reviews,
    ROUND(AVG(r.review_length), 2) AS avg_review_length
FROM reviews r
WHERE r.reviewer_score IS NOT NULL
  AND r.review_length IS NOT NULL
GROUP BY r.reviewer_score
ORDER BY r.reviewer_score;

SELECT -- distribuzione di review_length per categorie di score, raggruppando reviewer_score in fasce con CASE
    CASE
        WHEN r.reviewer_score < 6 THEN '0-5.9'
        WHEN r.reviewer_score < 8 THEN '6-7.9'
        WHEN r.reviewer_score < 9 THEN '8-8.9'
        ELSE '9-10'
    END AS score_category,
    COUNT(*) AS num_reviews,
    ROUND(AVG(r.review_length), 2) AS avg_review_length,
    ROUND(MIN(r.review_length), 2) AS min_review_length,
    ROUND(MAX(r.review_length), 2) AS max_review_length
FROM reviews r
WHERE r.reviewer_score IS NOT NULL
  AND r.review_length IS NOT NULL
GROUP BY score_category
ORDER BY score_category;

/*Correlazione lunghezza recensione vs Reviewer_Score*/
/*Questa formula restituisce il coefficiente di correlazione compreso tra -1 e 1.
Valore vicino a 1: più la recensione è lunga, più tende a essere alto lo score.
Valore vicino a -1: più la recensione è lunga, più tende a essere basso lo score.
Valore vicino a 0: relazione lineare debole o assente. */

SELECT 
    (
        COUNT(*) * SUM(r.review_length * r.reviewer_score)
        - SUM(r.review_length) * SUM(r.reviewer_score)
    ) /
    SQRT(
        (
            COUNT(*) * SUM(POW(r.review_length, 2))
            - POW(SUM(r.review_length), 2)
        ) *
        (
            COUNT(*) * SUM(POW(r.reviewer_score, 2))
            - POW(SUM(r.reviewer_score), 2)
        )
    ) AS correlation
FROM reviews r
WHERE r.review_length IS NOT NULL
  AND r.reviewer_score IS NOT NULL;

/*Correlazione per diverse fasce di score*/
SELECT
    CASE
        WHEN r.reviewer_score < 6 THEN '0-5.9'
        WHEN r.reviewer_score < 8 THEN '6-7.9'
        WHEN r.reviewer_score < 9 THEN '8-8.9'
        ELSE '9-10'
    END AS score_category,
    COUNT(*) AS num_reviews,
    (
        COUNT(*) * SUM(r.review_length * r.reviewer_score)
        - SUM(r.review_length) * SUM(r.reviewer_score)
    ) /
    SQRT(
        (
            COUNT(*) * SUM(POW(r.review_length, 2))
            - POW(SUM(r.review_length), 2)
        ) *
        (
            COUNT(*) * SUM(POW(r.reviewer_score, 2))
            - POW(SUM(r.reviewer_score), 2)
        )
    ) AS correlation
FROM reviews r
WHERE r.review_length IS NOT NULL
  AND r.reviewer_score IS NOT NULL
GROUP BY
    CASE
        WHEN r.reviewer_score < 6 THEN '0-5.9'
        WHEN r.reviewer_score < 8 THEN '6-7.9'
        WHEN r.reviewer_score < 9 THEN '8-8.9'
        ELSE '9-10'
    END
ORDER BY score_category;

/*Nel complesso, la correlazione risulta essere debole sia sul totale che nelle diverse fasce, pertanto la lunghezza della recensione sembra avere un impatto limitato sullo score assegnato.*/