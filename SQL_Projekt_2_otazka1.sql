--1)Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
WITH mzdy AS (
    SELECT DISTINCT
        rok,
        odvetvi,
        prumerna_mzda
    FROM t_michaela_perlikova_project_SQL_primary_final
),
mezirocni AS (
    SELECT
        rok,
        odvetvi,
        prumerna_mzda,
        LAG(prumerna_mzda) OVER (PARTITION BY odvetvi ORDER BY rok) AS mzda_predchozi_rok
    FROM mzdy
)
SELECT
    odvetvi,
    rok,
    mzda_predchozi_rok,
    prumerna_mzda,
    ROUND((prumerna_mzda - mzda_predchozi_rok) / mzda_predchozi_rok * 100, 2) AS mezirocni_zmena_procent,
    CASE
        WHEN prumerna_mzda > mzda_predchozi_rok THEN 'ROSTE'
        WHEN prumerna_mzda < mzda_predchozi_rok THEN 'KLESÁ'
        ELSE 'BEZ ZMĚNY'
    END AS trend
FROM mezirocni
WHERE mzda_predchozi_rok IS NOT NULL
ORDER BY odvetvi, rok;

--1) Souhrn za odvětví, který ukazuje v kolika letech mzda klesala
WITH mzdy AS (
    SELECT DISTINCT
        rok,
        odvetvi,
        prumerna_mzda
    FROM t_michaela_perlikova_project_SQL_primary_final
),
mezirocni AS (
    SELECT
        rok,
        odvetvi,
        prumerna_mzda,
        LAG(prumerna_mzda) OVER (PARTITION BY odvetvi ORDER BY rok) AS mzda_predchozi_rok
    FROM mzdy
)
SELECT
    odvetvi,
    COUNT(CASE WHEN prumerna_mzda < mzda_predchozi_rok THEN 1 END) AS pocet_let_s_poklesem,
    STRING_AGG(CASE WHEN prumerna_mzda < mzda_predchozi_rok THEN rok::text END, ', ' ORDER BY rok) AS roky_poklesu
FROM mezirocni
WHERE mzda_predchozi_rok IS NOT NULL
GROUP BY odvetvi
ORDER BY pocet_let_s_poklesem DESC, odvetvi;
