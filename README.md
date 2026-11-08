# SQL_projekt_michaela_perlikova_v2
Finální projekt ENGETO Datová akademie
# SQL projekt – Mzdy, ceny potravin a HDP v České republice

**Autorka:** Michaela Perlíková
**Kurz:** Engeto – Datová akademie

---

## Obsah

1. [Popis projektu](popis-projektu)
2. [Struktura repozitáře](struktura-repozitáře)
3. [Primární tabulka](primární-tabulka)
4. [Sekundární tabulka](sekundární-tabulka)
5. [Informace o výstupních datech](informace-o-výstupních-datech)
6. [Výzkumné otázky a odpovědi](výzkumné-otázky-a-odpovědi)
7. [Závěr projektu](závěr-projektu)

---

## Popis projektu

Cílem projektu je analyzovat **dostupnost základních potravin** v České republice, tedy porovnat vývoj průměrných mezd a cen potravin za společné období. Analýza je doplněna o HDP, GINI index a populaci evropských států.

Projekt odpovídá na pět výzkumných otázek:

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?
3. Která kategorie potravin zdražuje nejpomaleji?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (o více než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Zdrojové tabulky nebyly nijak upravovány. Všechny úpravy dat probíhají až při tvorbě nových tabulek a pohledu `vyvoj_cr`.

## Struktura repozitáře

| Soubor | Obsah |
|---|---|
| `SQL_Projekt_2_primarni_sekundarni_tabulka.sql` | vytvoření primární a sekundární tabulky |
| `SQL_Projekt_2_otazka1.sql` | otázka 1 – meziroční vývoj mezd v odvětvích |
| `SQL_Projekt_2_otazka2.sql` | otázka 2 – kolik mléka a chleba lze koupit za průměrnou mzdu |
| `SQL_Projekt_2_otazka3.sql` | otázka 3 – nejpomaleji zdražující potravina |
| `SQL_Projekt_2_otazka4.sql` | otázka 4 – nárůst cen potravin vs. nárůst mezd |
| `SQL_Projekt_2_otazka5.sql` | otázka 5 – vliv HDP (pohled `vyvoj_cr`) |
| `SQL_Projekt_2_kontrola_dat.sql` | kontrola výstupních dat – období, chybějící hodnoty |

Skripty je potřeba spouštět v tomto pořadí. Nejdříve se vytvoří obě tabulky, potom se spouští dotazy k jednotlivým otázkám.

---

## Primární tabulka

**Název:** `t_michaela_perlikova_project_SQL_primary_final`

**Zdrojové tabulky:** `czechia_payroll`, `czechia_payroll_industry_branch`, `czechia_price`, `czechia_price_category`

### Postup

**Mzdy** (CTE `mzdy`)
- typ hodnoty `5958` = průměrná hrubá mzda na zaměstnance,
- kalkulace `200` = přepočtený počet zaměstnanců (mzda přepočtená na plné úvazky),
- čtvrtletní hodnoty jsou zprůměrovány na **roční průměr za každé odvětví**.

**Ceny** (CTE `ceny`)
- **všechny kategorie potravin** (27 kategorií),
- pouze celorepublikové hodnoty (`region_code IS NULL`), bez krajského rozpadu,
- jednotlivá měření jsou zprůměrována na **roční průměr za každou potravinu**.

**Spojení**
Mzdy a ceny jsou spojeny přes *rok*. V tabulce tak zůstávají jen roky, pro které existují mzdy i ceny, tedy **společné období 2006–2018**.

### Sloupce

| Sloupec | Popis |
|---|---|
| `rok` | rok |
| `odvetvi` | název odvětví |
| `prumerna_mzda` | průměrná hrubá měsíční mzda v odvětví (Kč) |
| `potravina` | název kategorie potraviny |
| `mnozstvi` | množství, ke kterému se cena vztahuje |
| `jednotka` | jednotka množství (kg, l, g, ks) |
| `prumerna_cena` | průměrná cena potraviny (Kč) |

> Jeden řádek tabulky = rok × odvětví × potravina. Mzda odvětví se proto opakuje u každé potraviny a cena potraviny u každého odvětví. Dotazy k otázkám si nejdříve v CTE vyberou jen jedinečné kombinace (`SELECT DISTINCT`).

---

## Sekundární tabulka

**Název:** `t_michaela_perlikova_project_SQL_secondary_final`

**Zdrojové tabulky:** `economies`, `countries`

### Postup

- spojení tabulek `economies` a `countries` přes název státu,
- pouze evropské státy (`continent = 'Europe'`),
- období 2006–2018, stejné jako v primární tabulce.

### Sloupce

| Sloupec | Popis |
|---|---|
| `stat` | název státu |
| `stat_zkratka` | zkratka státu (ČR = `CZ`) |
| `rok` | rok |
| `populace` | počet obyvatel |
| `HDP` | hrubý domácí produkt (USD) |
| `GINI_index` | GINI koeficient (míra příjmové nerovnosti) |

Data za Českou republiku se používají v otázce 5.

---

## Informace o výstupních datech

### Primární tabulka

| Ukazatel | Hodnota |
|---|---|
| Období | 2006–2018 (13 let) |
| Počet odvětví | 19 |
| Počet kategorií potravin | 27 |
| Počet řádků | 6 498 |
| Chybějící hodnoty mezd / cen | 0 / 0 |

**Neúplná data:**
- **Jakostní víno bílé** má data pouze za roky **2015–2018** (chybí 9 let). V otázce 3 má proto jen 3 meziroční změny a jeho výsledek je méně spolehlivý. V otázkách 4 a 5 vstupuje do průměru až od roku 2016.
- Ceny se vztahují k různým množstvím. Většina potravin je za 1 kg nebo 1 l, výjimky jsou jogurt (150 g), pivo (0,5 l), víno (0,75 l) a vejce (10 ks). Meziroční změny v % to neovlivňuje.

### Sekundární tabulka

| Ukazatel | Hodnota |
|---|---|
| Období | 2006–2018 |
| Počet států | 45 |
| Počet řádků | 585 |
| Chybějící HDP | 37 řádků |
| Chybějící GINI index | 124 řádků (18 států) |

**Kde hodnoty chybí:**
- **HDP:** Gibraltar nemá HDP za žádný rok. Faerské ostrovy a Lichtenštejnsko ho mají jen za jeden rok z třinácti.
- **GINI index:** zcela chybí u Andorry, Faerských ostrovů, Gibraltaru, Lichtenštejnska, Monaka a San Marina. U dalších 12 států chybí jen v některých letech.
- **Česká republika** má HDP, GINI index i populaci za všechny roky, takže otázku 5 chybějící hodnoty neovlivňují.

### Metodické poznámky

- Průměrná mzda za ČR (otázky 2, 4, 5) je **prostý průměr mezd všech 19 odvětví**. Není vážená počtem zaměstnanců, proto se může lišit od oficiální průměrné mzdy ČSÚ.
- Nárůst cen potravin v daném roce (otázky 4, 5) je **průměr meziročních změn v % všech potravin**. Každá potravina má stejnou váhu bez ohledu na spotřebu.
- Meziroční změny se počítají jen mezi dvěma po sobě jdoucími roky, takže mezera v datech (víno) výsledek nezkresluje.

---

## Výzkumné otázky a odpovědi

### 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

**Skript:** `SQL_Projekt_2_otazka1.sql`
**Postup:** Pro každé odvětví je pomocí okenní funkce `LAG` spočtena meziroční změna průměrné mzdy. Druhý dotaz shrnuje, v kolika letech mzda v každém odvětví klesla.

**Odpověď:** Mzdy **dlouhodobě rostou ve všech odvětvích, meziročně ale nerostly vždy**. Meziroční pokles se objevil v **16 z 19 odvětví**.

**Odvětví s nejvíce poklesy:**

| Odvětví | Počet let s poklesem | Roky poklesu |
|---|---|---|
| Těžba a dobývání | 4 | 2009, 2013, 2014, 2016 |
| Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu | 3 | 2011, 2013, 2015 |
| Profesní, vědecké a technické činnosti | 2 | 2010, 2013 |
| Ubytování, stravování a pohostinství | 2 | 2009, 2011 |
| Veřejná správa a obrana; povinné sociální zabezpečení | 2 | 2010, 2011 |
| Činnosti v oblasti nemovitostí | 2 | 2009, 2013 |

**Hlavní zjištění:**
- **Rok 2013** byl nejhorší: mzda klesla v **11 odvětvích**.
- Další skupina poklesů přišla v letech **2009–2011**, tedy po hospodářské krizi. Týkala se hlavně odvětví citlivých na ekonomický cyklus (těžba, ubytování a stravování, nemovitosti) a od roku 2010 i veřejného sektoru (veřejná správa, vzdělávání).
- **Největší meziroční pokles:** Peněžnictví a pojišťovnictví v roce 2013 (**−8,83 %**).
- **Nejméně stabilní odvětví** je Těžba a dobývání se 4 poklesy.
- **Bez jediného poklesu:** Zdravotní a sociální péče, Zpracovatelský průmysl a Ostatní činnosti. 

---

### 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?

**Skript:** `SQL_Projekt_2_otazka2.sql`
**Postup:** Průměrná mzda všech odvětví vydělená průměrnou cenou mléka a chleba v prvním (2006) a posledním (2018) společném roce. Roky se neberou napevno, ale z dat (`MIN` a `MAX`).

**Odpověď:**

| Potravina | 2006 | 2018 | Změna |
|---|---|---|---|
| Mléko polotučné pasterované | **1 466 l** | **1 670 l** | +204 l |
| Chléb konzumní kmínový | **1 313 kg** | **1 365 kg** | +52 kg |

| Ukazatel | 2006 | 2018 | Změna |
|---|---|---|---|
| Průměrná mzda | 21 165 Kč | 33 091 Kč |
| Cena mléka (1 l) | 14,44 Kč | 19,82 Kč |
| Cena chleba (1 kg) | 16,12 Kč | 24,24 Kč |

**Hlavní zjištění:**
- Za průměrnou mzdu bylo možné v roce 2018 koupit **více mléka i chleba** než v roce 2006, protože i mzdy rostly.
- U **mléka** je zlepšení výrazné (+204 l).
- U **chleba** je zlepšení jen mírné (52 kg).

---

### 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

**Skript:** `SQL_Projekt_2_otazka3.sql`
**Postup:** U každé potraviny je pomocí `LAG` spočtena meziroční změna ceny v %. Z těchto změn je spočten průměr za celé období.

**Odpověď:** Nejpomaleji zdražuje **cukr krystalový**. Jeho cena dokonce v průměru **klesala o 1,92 % ročně**.

**Nejpomaleji zdražující potraviny:**

| Pořadí | Potravina | Průměrná meziroční změna |
|---|---|---|
| 1. | Cukr krystalový | **−1,92 %** |
| 2. | Rajská jablka červená kulatá | −0,74 % |
| 3. | Banány žluté | 0,81 % |
| 4. | Vepřová pečeně s kostí | 0,99 % |
| 5. | Přírodní minerální voda uhličitá | 1,03 % |

**Nejrychleji zdražující potraviny:**

| Pořadí | Potravina | Průměrná meziroční změna |
|---|---|---|
| 27. | Papriky | 7,29 % |
| 26. | Máslo | 6,67 % |
| 25. | Vejce slepičí čerstvá | 5,55 % |
| 24. | Těstoviny vaječné | 5,26 % |
| 23. | Pšeničná mouka hladká | 5,24 % |

**Hlavní zjištění:**
- Pouze **dvě potraviny v průměru zlevňovaly**: cukr a rajská jablka.
- Rozdíl mezi nejpomaleji a nejrychleji zdražující potravinou je přes 9 procentních bodů ročně.
- Rychle zdražovaly hlavně základní potraviny a suroviny (máslo, vejce, mouka, těstoviny, rýže).
- Jakostní víno bílé (2,70 %) má data jen za 3 meziroční změny, jeho výsledek je proto jen orientační.

---

### 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

**Skript:** `SQL_Projekt_2_otazka4.sql`
**Postup:** Nárůst cen v roce je průměr meziročních změn všech potravin, nárůst mezd je meziroční změna průměrné mzdy všech odvětví. „Výrazně vyšší“ znamená, že ceny rostly o více než **10 procentních bodů** rychleji než mzdy.

**Odpověď:** **Ne, takový rok v datech neexistuje.** Ceny potravin nikdy nerostly o více než 10 procentních bodů rychleji než mzdy.

| Rok | Nárůst cen | Nárůst mezd | Rozdíl (p. b.) |
|---|---|---|---|
| 2007 | 9,26 % | 6,88 % | +2,38 |
| 2008 | 8,91 % | 7,69 % | +1,21 |
| 2009 | −6,58 % | 3,07 % | −9,65 |
| 2010 | 1,52 % | 1,91 % | −0,39 |
| 2011 | 4,85 % | 2,33 % | +2,51 |
| 2012 | 7,47 % | 2,93 % | +4,54 |
| **2013** | **6,01 %** | **−1,56 %** | **+7,56** |
| 2014 | −0,62 % | 2,57 % | −3,20 |
| 2015 | −0,69 % | 2,60 % | −3,29 |
| 2016 | −1,41 % | 3,64 % | −5,05 |
| 2017 | 7,06 % | 6,17 % | +0,89 |
| 2018 | 2,41 % | 7,70 % | −5,29 |

**Hlavní zjištění:**
- Hranici 10 p. b. se nejvíce přiblížil **rok 2013** (rozdíl +7,56 p. b.). Ceny potravin vzrostly o 6,01 %, zatímco průměrná mzda klesla o 1,56 %.
- Ceny rostly rychleji než mzdy v **6 letech** (2007, 2008, 2011, 2012, 2013, 2017), mzdy rostly rychleji také v **6 letech**.
- Opačný extrém je **rok 2009**: ceny potravin klesly o 6,58 % a mzdy vzrostly o 3,07 %, mzdy tedy předběhly ceny o 9,65 p. b.

---

### 5) Má výška HDP vliv na změny ve mzdách a cenách potravin?

**Skript:** `SQL_Projekt_2_otazka5.sql`
**Postup:** Pohled `vyvoj_cr` obsahuje pro každý rok meziroční růst HDP ČR, mezd a cen potravin. Pomocí `LEAD` se k růstu HDP přiřadí i růst mezd a cen v následujícím roce. Roky jsou dále rozděleny na roky s nadprůměrným růstem HDP a ostatní roky.

**Meziroční vývoj:**

| Rok | Růst HDP | Růst mezd | Růst mezd (následující rok) | Růst cen | Růst cen (následující rok) |
|---|---|---|---|---|---|
| 2007 | 5,57 % | 6,88 % | 7,69 % | 9,26 % | 8,91 % |
| 2008 | 2,69 % | 7,69 % | 3,07 % | 8,91 % | −6,58 % |
| 2009 | −4,66 % | 3,07 % | 1,91 % | −6,58 % | 1,52 % |
| 2010 | 2,43 % | 1,91 % | 2,33 % | 1,52 % | 4,85 % |
| 2011 | 1,76 % | 2,33 % | 2,93 % | 4,85 % | 7,47 % |
| 2012 | −0,79 % | 2,93 % | −1,56 % | 7,47 % | 6,01 % |
| 2013 | −0,05 % | −1,56 % | 2,57 % | 6,01 % | −0,62 % |
| 2014 | 2,26 % | 2,57 % | 2,60 % | −0,62 % | −0,69 % |
| 2015 | 5,39 % | 2,60 % | 3,64 % | −0,69 % | −1,41 % |
| 2016 | 2,54 % | 3,64 % | 6,17 % | −1,41 % | 7,06 % |
| 2017 | 5,17 % | 6,17 % | 7,70 % | 7,06 % | 2,41 % |
| 2018 | 3,20 % | 7,70 % | – | 2,41 % | – |

**Porovnání skupin let:**

| Skupina | Počet let | Prům. růst HDP | Prům. Růst mezd | Růst mezd – následující rok | Prům. Růst cen | Růst cen – následující rok |
|---|---|---|---|---|---|---|
| Výrazný růst HDP (2007, 2008, 2010, 2014–2018) | 8 | 3,66 % | **4,90 %** | **4,74 %** | 3,31 % | 2,08 % |
| Ostatní roky (2009, 2011–2013) | 4 | −0,94 % | 1,69 % | 1,46 % | 2,94 % | 3,60 % |


**Odpověď:**

**Mzdy – ANO, vliv HDP je patrný.**
- V letech s nadprůměrným růstem HDP rostly mzdy výrazně rychleji (4,90 % proti 1,69 %), a to ve stejném i v následujícím roce.
- Příklad: po poklesu HDP v roce 2009 (−4,66 %) se růst mezd zpomalil na 1,91 % v roce 2010. Po stagnaci HDP v letech 2012–2013 mzdy v roce 2013 dokonce klesly. Naopak po silném růstu HDP v letech 2015 a 2017 (přes 5 %) se růst mezd v letech 2016–2018 postupně zrychlil až na 7,70 %.

**Ceny potravin – vliv HDP se neprokázal.**
- Po letech s nadprůměrným růstem HDP rostly ceny dokonce pomaleji (2,08 %) než po ostatních letech (3,60 %).
- Příklad: v letech 2012 a 2013 HDP mírně klesalo, ceny potravin přesto vzrostly o 7,47 % a 6,01 %. Naopak v roce 2015 HDP vzrostlo o 5,39 % a ceny potravin klesly.
- Ceny potravin pravděpodobně ovlivňují spíše jiné faktory (úroda, ceny surovin a energií, světové ceny potravin).

## Závěr projektu

**Shrnutí odpovědí:**

| Otázka | Odpověď |
|---|---|
| 1. Rostou mzdy ve všech odvětvích? | Dlouhodobě ano, ve všech 19 odvětvích. Meziročně ale mzdy klesly v 16 odvětvích (25 případů), nejvíce v roce 2013 (11 odvětví). Bez poklesu byla jen 3 odvětví. |
| 2. Kolik mléka a chleba za mzdu? | 2006: 1 466 l mléka a 1 313 kg chleba. 2018: 1 670 l mléka a 1 365 kg chleba. Kupní síla vzrostla, u mléka výrazněji. |
| 3. Nejpomaleji zdražující potravina? | Cukr krystalový (−1,92 % ročně), dále rajská jablka (−0,74 %). Obě v průměru zlevňovaly. |
| 4. Rok, kdy ceny rostly o 10 % rychleji než mzdy? | Neexistuje. Nejvyšší rozdíl byl v roce 2013 (+7,56 p. b.). |
| 5. Vliv HDP? | Na mzdy ano, hlavně v následujícím roce. Na ceny potravin se vliv neprokázal. |

**Celkové zhodnocení:**
- Růst mezd byl v dlouhodobém pohledu stabilní. Krátkodobě ho ale ovlivnila hospodářská krize (2009–2011) a stagnace ekonomiky v letech 2012–2013, kdy mzdy klesaly ve většině odvětví.
- Ceny potravin kolísají mnohem více než mzdy (od −6,58 % do +9,26 % ročně) a jejich vývoj se liší podle druhu potraviny. Některé potraviny zlevňovaly, jiné zdražovaly o 5–7 % ročně.
- Pro běžnou domácnost to znamená, že dostupnost potravin se zlepšovala hlavně díky růstu mezd. Ten souvisí s výkonem ekonomiky (HDP), zatímco ceny potravin se vyvíjejí převážně nezávisle na něm.
