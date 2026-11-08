-- primarni tabulka
CREATE TABLE t_michaela_perlikova_project_SQL_primary_final AS
WITH mzdy AS (
    SELECT
        cp.payroll_year AS rok,
        ib.name AS odvetvi,
        ROUND(AVG(cp.value)::numeric, 2) AS prumerna_mzda
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch ib
        ON cp.industry_branch_code = ib.code
    WHERE cp.value_type_code = 5958
      AND cp.calculation_code = 200
    GROUP BY cp.payroll_year, ib.name
),
ceny AS (
    SELECT
        EXTRACT(YEAR FROM pr.date_from)::int AS rok,
        pc.name AS potravina,
        pc.price_value AS mnozstvi,
        pc.price_unit AS jednotka,
        ROUND(AVG(pr.value)::numeric, 2) AS prumerna_cena
    FROM czechia_price pr
    JOIN czechia_price_category pc
        ON pr.category_code = pc.code
    WHERE pr.region_code IS NULL
    GROUP BY EXTRACT(YEAR FROM pr.date_from), pc.name, pc.price_value, pc.price_unit
)
SELECT
    m.rok,
    m.odvetvi,
    m.prumerna_mzda,
    c.potravina,
    c.mnozstvi,
    c.jednotka,
    c.prumerna_cena
FROM mzdy m
JOIN ceny c
    ON m.rok = c.rok
ORDER BY m.rok, m.odvetvi, c.potravina;

-- sekundární tabulka
CREATE TABLE t_michaela_perlikova_project_SQL_secondary_final AS
SELECT 
    e.country AS stat,
    c.abbreviation AS stat_zkratka,
    e.year AS rok,
    e.population AS populace,
    e.gdp AS "HDP",
    e.gini AS "GINI_index"
FROM economies e
JOIN countries c
    ON e.country = c.country
WHERE e.year BETWEEN 2006 AND 2018
  AND c.continent = 'Europe';
