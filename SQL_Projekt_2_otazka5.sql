--5 Má výška HDP vliv na změny ve mzdách a cenách potravin?Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na
-- cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
DROP VIEW IF EXISTS vyvoj_cr;

CREATE VIEW vyvoj_cr AS
WITH hdp AS (
    SELECT
        rok,
        "HDP" AS hdp,
        ("HDP" - LAG("HDP") OVER (ORDER BY rok)) / LAG("HDP") OVER (ORDER BY rok) * 100 AS narust_hdp
    FROM t_michaela_perlikova_project_SQL_secondary_final
    WHERE stat_zkratka = 'CZ'
),
mzdy_odvetvi AS (
    SELECT DISTINCT
        rok,
        odvetvi,
        prumerna_mzda
    FROM t_michaela_perlikova_project_SQL_primary_final
),
mzdy AS (
    SELECT
        rok,
        AVG(prumerna_mzda) AS prumerna_mzda
    FROM mzdy_odvetvi
    GROUP BY rok
),
narust_mezd AS (
    SELECT
        rok,
        (prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY rok))
            / LAG(prumerna_mzda) OVER (ORDER BY rok) * 100 AS narust_mezd
    FROM mzdy
),
ceny AS (
    SELECT DISTINCT
        rok,
        potravina,
        prumerna_cena
    FROM t_michaela_perlikova_project_SQL_primary_final
),
mezirocni_ceny AS (
    SELECT
        rok,
        LAG(rok) OVER (PARTITION BY potravina ORDER BY rok) AS predchozi_rok,
        (prumerna_cena - LAG(prumerna_cena) OVER (PARTITION BY potravina ORDER BY rok))
            / LAG(prumerna_cena) OVER (PARTITION BY potravina ORDER BY rok) * 100 AS zmena_ceny
    FROM ceny
),
narust_cen AS (
    SELECT
        rok,
        AVG(zmena_ceny) AS narust_cen
    FROM mezirocni_ceny
    WHERE predchozi_rok = rok - 1
    GROUP BY rok
)
SELECT
    h.rok,
    ROUND(h.narust_hdp::numeric, 2) AS narust_hdp,
    ROUND(m.narust_mezd, 2) AS narust_mezd,
    ROUND(c.narust_cen, 2) AS narust_cen
FROM hdp h
JOIN narust_mezd m
    ON h.rok = m.rok
JOIN narust_cen c
    ON h.rok = c.rok
WHERE h.narust_hdp IS NOT NULL;

--5 růst HDP, mezd a cen ve stejném a následujícím roce
SELECT
    rok,
    narust_hdp,
    narust_mezd,
    LEAD(narust_mezd) OVER (ORDER BY rok) AS narust_mezd_nasledujici_rok,
    narust_cen,
    LEAD(narust_cen) OVER (ORDER BY rok) AS narust_cen_nasledujici_rok
FROM vyvoj_cr
ORDER BY rok;
--5 Porovnání let s výrazným růstem HDP (nad průměrem období) a ostatních let
WITH vyvoj AS (
    SELECT
        rok,
        narust_hdp,
        narust_mezd,
        LEAD(narust_mezd) OVER (ORDER BY rok) AS narust_mezd_nasledujici_rok,
        narust_cen,
        LEAD(narust_cen) OVER (ORDER BY rok) AS narust_cen_nasledujici_rok,
        CASE
            WHEN narust_hdp > AVG(narust_hdp) OVER () THEN 'výrazný růst HDP'
            ELSE 'ostatní roky'
        END AS skupina
    FROM vyvoj_cr
)
SELECT
    skupina,
    COUNT(*) AS pocet_let,
    STRING_AGG(rok::text, ', ' ORDER BY rok) AS roky,
    ROUND(AVG(narust_hdp), 2) AS prumerny_narust_hdp,
    ROUND(AVG(narust_mezd), 2) AS prumerny_narust_mezd,
    ROUND(AVG(narust_mezd_nasledujici_rok), 2) AS prumerny_narust_mezd_nasledujici_rok,
    ROUND(AVG(narust_cen), 2) AS prumerny_narust_cen,
    ROUND(AVG(narust_cen_nasledujici_rok), 2) AS prumerny_narust_cen_nasledujici_rok
FROM vyvoj
GROUP BY skupina
ORDER BY skupina DESC;
