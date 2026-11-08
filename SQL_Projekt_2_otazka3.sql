--3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
WITH ceny AS (
    SELECT DISTINCT
        rok,
        potravina,
        prumerna_cena
    FROM t_michaela_perlikova_project_SQL_primary_final
),
mezirocni AS (
    SELECT
        rok,
        potravina,
        prumerna_cena,
        LAG(rok) OVER (PARTITION BY potravina ORDER BY rok) AS predchozi_rok,
        LAG(prumerna_cena) OVER (PARTITION BY potravina ORDER BY rok) AS cena_predchozi_rok
    FROM ceny
)
SELECT
    potravina,
    MIN(predchozi_rok) AS od_roku,
    MAX(rok) AS do_roku,
    COUNT(*) AS pocet_mezirocnich_zmen,
    ROUND(AVG((prumerna_cena - cena_predchozi_rok) / cena_predchozi_rok * 100), 2) AS prumerny_mezirocni_narust_procent
FROM mezirocni
WHERE predchozi_rok = rok - 1
GROUP BY potravina
ORDER BY prumerny_mezirocni_narust_procent ASC;
