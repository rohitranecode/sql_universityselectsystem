USE  UNIVERSITYDB;

-- QUERY 1 Country Performance Overview --
SELECT
    l.country,
    COUNT(u.id) AS number_of_universities,
    ROUND(AVG(q.ranking), 2) AS average_rank,
    ROUND(AVG(f.average_fee), 2) AS average_fee
FROM
    university u
JOIN
    location l ON u.id = l.uni_id
JOIN
    qs_ranking q ON u.id = q.uni_id
JOIN
    fees f ON u.id = f.uni_id
GROUP BY
    l.country
ORDER BY
    number_of_universities DESC;
    
-- QUERY 2 High-Value Universities (Placement vs. Fees) --    
SELECT
    u.name,
    l.country,
    q.ranking
FROM
    university u
JOIN
    location l ON u.id = l.uni_id
JOIN
    qs_ranking q ON u.id = q.uni_id
JOIN
    fees f ON u.id = f.uni_id
JOIN
    placement p ON u.id = p.uni_id
WHERE
    p.average_package_usd > 90000 AND f.average_fee < 60000;
    
-- QUERY 3 Top University in California --
SELECT
    u.name,
    q.ranking,
    l.city
FROM
    university u
JOIN
    qs_ranking q ON u.id = q.uni_id
JOIN
    location l ON u.id = l.uni_id
WHERE
    l.state = 'California'
ORDER BY
    q.ranking ASC
LIMIT 1;

-- QUERY 4 National Placement Statistics --
SELECT
    l.country,
    ROUND(AVG(p.percent_out_of_total), 2) AS average_placement_percent,
    ROUND(AVG(p.average_package_usd), 2) AS average_package
FROM
    university u
JOIN
    location l ON u.id = l.uni_id
JOIN
    placement p ON u.id = p.uni_id
GROUP BY
    l.country
HAVING
    COUNT(u.id) > 3;

-- QUERY 5 Historical Universities' Modern Standing --
SELECT
    u.name,
    u.year_established,
    q.ranking,
    p.average_package_usd
FROM
    university u
JOIN
    qs_ranking q ON u.id = q.uni_id
JOIN
    placement p ON u.id = p.uni_id
WHERE
    u.year_established < 1800
ORDER BY
    q.ranking ASC;
    
-- QUERY 6 Financial "Return on Investment" (ROI) --
SELECT
    u.name,
    l.country,
    ROUND(p.average_package_usd / f.average_fee, 2) AS ROI
FROM
    university u
JOIN
    location l ON u.id = l.uni_id
JOIN
    fees f ON u.id = f.uni_id
JOIN
    placement p ON u.id = p.uni_id
ORDER BY
    ROI DESC
LIMIT 10;

-- QUERY 7 Global University Hubs --
SELECT
    l.city,
    l.country,
    COUNT(u.id) AS number_of_universities
FROM
    university u
JOIN
    location l ON u.id = l.uni_id
GROUP BY
    l.city, l.country
HAVING
    COUNT(u.id) > 2
ORDER BY
    number_of_universities DESC;

--  QUERY 8 Fee Range vs. Ranking Tier
SELECT
    CASE
        WHEN q.ranking BETWEEN 1 AND 50 THEN 'Rank 1-50'
        WHEN q.ranking BETWEEN 51 AND 100 THEN 'Rank 51-100'
    END AS ranking_tier,
    ROUND(AVG(f.highest_fee - f.lowest_fee), 2) AS average_fee_range
FROM
    fees f
JOIN
    qs_ranking q ON f.uni_id = q.uni_id
WHERE
    q.ranking <= 100
GROUP BY
    ranking_tier;

-- QUERY 9 Most Expensive University in Each Country
WITH RankedFees AS (
    SELECT
        l.country,
        u.name AS university_name,
        f.average_fee,
        ROW_NUMBER() OVER(PARTITION BY l.country ORDER BY f.average_fee DESC) as rn
    FROM
        university u
    JOIN
        location l ON u.id = l.uni_id
    JOIN
        fees f ON u.id = f.uni_id
)
SELECT
    country,
    university_name,
    average_fee AS highest_average_fee
FROM
    RankedFees
WHERE
    rn = 1;

-- QUERY 10 Salary by Ranking Tier Analysis
SELECT
    CASE
        WHEN q.ranking BETWEEN 1 AND 25 THEN 'Rank 1-25'
        WHEN q.ranking BETWEEN 26 AND 50 THEN 'Rank 26-50'
        WHEN q.ranking BETWEEN 51 AND 75 THEN 'Rank 51-75'
        WHEN q.ranking BETWEEN 76 AND 100 THEN 'Rank 76-100'
    END AS ranking_tier,
    ROUND(AVG(p.average_package_usd), 2) AS average_package
FROM
    placement p
JOIN
    qs_ranking q ON p.uni_id = q.uni_id
GROUP BY
    ranking_tier
ORDER BY
    MIN(q.ranking);

--  QUERY 11 Top Engineering Schools
SELECT
    u.name,
    q.ranking,
    l.country
FROM
    university u
JOIN
    qs_ranking q ON u.id = q.uni_id
JOIN
    location l ON u.id = l.uni_id
JOIN
    courses c ON u.id = c.uni_id
WHERE
    c.engineering = 'Yes'
ORDER BY
    q.ranking ASC
LIMIT 10;

-- QUERY 12 Law & Medicine Hubs in the USA
SELECT
    u.name,
    f.average_fee AS average_tuition_fee
FROM
    university u
JOIN
    location l ON u.id = l.uni_id
JOIN
    courses c ON u.id = c.uni_id
JOIN
    fees f ON u.id = f.uni_id
WHERE
    l.country = 'USA' AND c.law = 'Yes' AND c.medicine = 'Yes';

-- QUERY 13 Specialized Universities Analysis (Placement)
SELECT
    CASE
        WHEN c.engineering = 'Yes' THEN 'Offers Engineering'
        ELSE 'Does Not Offer Engineering'
    END AS engineering_status,
    ROUND(AVG(p.average_package_usd), 2) AS average_package
FROM
    placement p
JOIN
    courses c ON p.uni_id = c.uni_id
GROUP BY
    engineering_status;

-- QUERY 14 Humanities in the Top Tier
SELECT
    COUNT(u.id) AS top_25_with_humanities
FROM
    university u
JOIN
    qs_ranking q ON u.id = q.uni_id
JOIN
    courses c ON u.id = c.uni_id
WHERE
    q.ranking <= 25 AND c.humanities = 'Yes';

-- QUERY 15 Course Availability by Country.
SELECT
    l.country,
    COUNT(c.uni_id) AS universities_with_medicine
FROM
    courses c
JOIN
    location l ON c.uni_id = l.uni_id
WHERE
    c.medicine = 'Yes'
GROUP BY
    l.country
ORDER BY
    universities_with_medicine DESC;
