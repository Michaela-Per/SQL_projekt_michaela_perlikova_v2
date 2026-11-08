--4 Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH ceny AS (
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
            / LAG(prumerna_cena) OVER (PARTITION BY potravina ORDER BY rok) * 100 AS zmena_ceny_procent
    FROM ceny
),
narust_cen AS (
    SELECT
        rok,
        AVG(zmena_ceny_procent) AS narust_cen_procent
    FROM mezirocni_ceny
    WHERE predchozi_rok = rok - 1
    GROUP BY rok
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
            / LAG(prumerna_mzda) OVER (ORDER BY rok) * 100 AS narust_mezd_procent
    FROM mzdy
)
SELECT
    c.rok,
    ROUND(c.narust_cen_procent, 2) AS narust_cen_procent,
    ROUND(m.narust_mezd_procent, 2) AS narust_mezd_procent,
    ROUND(c.narust_cen_procent - m.narust_mezd_procent, 2) AS rozdil_procentni_body,
    CASE
        WHEN c.narust_cen_procent - m.narust_mezd_procent > 10 THEN 'ANO'
        ELSE 'NE'
    END AS ceny_vyssi_o_10_procent
FROM narust_cen c
JOIN narust_mezd m
    ON c.rok = m.rok
WHERE m.narust_mezd_procent IS NOT NULL
ORDER BY c.rok;