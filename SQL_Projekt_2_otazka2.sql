--2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
WITH obdobi AS (
    SELECT
        MIN(rok) AS prvni_rok,
        MAX(rok) AS posledni_rok
    FROM t_michaela_perlikova_project_SQL_primary_final
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
potraviny AS (
    SELECT DISTINCT
        rok,
        potravina,
        prumerna_cena,
        jednotka
    FROM t_michaela_perlikova_project_SQL_primary_final
    WHERE potravina IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
)
SELECT
    p.potravina,
    p.rok,
    ROUND(m.prumerna_mzda, 2) AS prumerna_mzda,
    p.prumerna_cena,
    ROUND(m.prumerna_mzda / p.prumerna_cena, 0) AS lze_koupit,
    p.jednotka
FROM potraviny p
JOIN mzdy m
    ON p.rok = m.rok
JOIN obdobi o
    ON p.rok IN (o.prvni_rok, o.posledni_rok)
ORDER BY p.potravina, p.rok;
