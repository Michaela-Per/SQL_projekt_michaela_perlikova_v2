-- a) Období a rozsah primární tabulky
SELECT
    MIN(rok) AS prvni_rok,
    MAX(rok) AS posledni_rok,
    COUNT(DISTINCT rok) AS pocet_let,
    COUNT(DISTINCT odvetvi) AS pocet_odvetvi,
    COUNT(DISTINCT potravina) AS pocet_potravin,
    COUNT(*) AS pocet_radku
FROM t_michaela_perlikova_project_SQL_primary_final;


-- b) Potraviny, které nemají data za celé období
WITH pocet_let AS (
    SELECT COUNT(DISTINCT rok) AS celkem
    FROM t_michaela_perlikova_project_SQL_primary_final
)
SELECT
    t.potravina,
    MIN(t.rok) AS od_roku,
    MAX(t.rok) AS do_roku,
    COUNT(DISTINCT t.rok) AS pocet_let_s_daty,
    p.celkem - COUNT(DISTINCT t.rok) AS pocet_chybejicich_let
FROM t_michaela_perlikova_project_SQL_primary_final t
CROSS JOIN pocet_let p
GROUP BY t.potravina, p.celkem
HAVING COUNT(DISTINCT t.rok) < p.celkem;


-- c) Chybějící hodnoty mezd ve zdrojových datech (v rámci společného období)
--     Roční průměr je u těchto odvětví spočten z méně než 4 čtvrtletí.
WITH spolecne_roky AS (
    SELECT DISTINCT rok
    FROM t_michaela_perlikova_project_SQL_primary_final
)
SELECT
    cp.payroll_year AS rok,
    cp.payroll_quarter AS ctvrtleti,
    ib.name AS odvetvi
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch ib
    ON cp.industry_branch_code = ib.code
JOIN spolecne_roky sr
    ON cp.payroll_year = sr.rok
WHERE cp.value_type_code = 5958
  AND cp.calculation_code = 200
  AND cp.value IS NULL
ORDER BY rok, ctvrtleti, odvetvi;


-- d) Chybějící hodnoty v primární tabulce
SELECT
    COUNT(*) AS pocet_radku,
    COUNT(*) - COUNT(prumerna_mzda) AS chybi_mzda,
    COUNT(*) - COUNT(prumerna_cena) AS chybi_cena
FROM t_michaela_perlikova_project_SQL_primary_final;


-- e) Sekundární tabulka – počet států a chybějící hodnoty celkem
SELECT
    COUNT(DISTINCT stat) AS pocet_statu,
    COUNT(*) AS pocet_radku,
    COUNT(*) - COUNT("HDP") AS chybi_hdp,
    COUNT(*) - COUNT("GINI_index") AS chybi_gini
FROM t_michaela_perlikova_project_SQL_secondary_final;

-- f) Sekundární tabulka – státy, u kterých některé hodnoty chybí
SELECT
    stat,
    COUNT(*) AS pocet_let,
    COUNT(*) - COUNT("HDP") AS chybi_hdp,
    COUNT(*) - COUNT("GINI_index") AS chybi_gini
FROM t_michaela_perlikova_project_SQL_secondary_final
GROUP BY stat
HAVING COUNT(*) - COUNT("HDP") > 0
    OR COUNT(*) - COUNT("GINI_index") > 0
ORDER BY stat;


