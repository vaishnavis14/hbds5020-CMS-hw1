-- Question 1

SELECT COUNT(*) AS num_rows,
	COUNT(DISTINCT(DESYNPUF_ID)) AS unique_num_beneficiaries,
	COUNT(DISTINCT(SP_STATE_CODE)) AS unique_num_states,
	COUNT(DISTINCT(BENE_COUNTY_CD)) AS unique_num_counties
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1;

-- Answer
-- 116352	116352	52	307

-- Question 2

SELECT 
    MIN(TIMESTAMPDIFF(YEAR, BENE_BIRTH_DT, DATE('2008-12-31'))) AS min_age,
    AVG(TIMESTAMPDIFF(YEAR, BENE_BIRTH_DT, DATE('2008-12-31'))) AS avg_age,
    MAX(TIMESTAMPDIFF(YEAR, BENE_BIRTH_DT, DATE('2008-12-31'))) AS max_age,
    COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(YEAR, BENE_BIRTH_DT, DATE('2008-12-31')) < 65 THEN DESYNPUF_ID END) AS under_65,
    COUNT(DISTINCT CASE WHEN YEAR(BENE_DEATH_DT) = 2008 THEN DESYNPUF_ID END) AS died_in_2008
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1;

-- Answer
-- 25	71.6472	99	19120	1814

-- Question 3

WITH total_beneficiaries AS (
    SELECT COUNT(DISTINCT DESYNPUF_ID) AS total_count
    FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
    WHERE SP_DEPRESSN = 1
)
SELECT 
    BENE_SEX_IDENT_CD AS sex,
    COUNT(DISTINCT DESYNPUF_ID) AS num_beneficiaries_with_depression,
    CONCAT(FORMAT(COUNT(DISTINCT DESYNPUF_ID) * 100.0 / (SELECT total_count FROM total_beneficiaries), 2), '%') AS Percentage
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
WHERE SP_DEPRESSN = 1
GROUP BY BENE_SEX_IDENT_CD;

-- Answer
-- 1	10272	41.35%
-- 2	14568	58.65%

-- Question 4 

SELECT
	CASE 
		WHEN TIMESTAMPDIFF(YEAR, BENE_BIRTH_DT, DATE('2008-12-31')) < 65 THEN 1 ELSE 0 
	END AS age_less_than_65,
	AVG(
        (CASE WHEN SP_ALZHDMTA = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_CHF = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_CHRNKIDN = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_CNCR = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_COPD = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_DEPRESSN = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_DIABETES = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_ISCHMCHT = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_OSTEOPRS = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_RA_OA = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN SP_STRKETIA = 1 THEN 1 ELSE 0 END)
    ) AS avg_n_chronic_conditions
	FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
	GROUP BY age_less_than_65
	ORDER BY age_less_than_65 DESC;

-- Answer
-- 1	2.2214
-- 0	2.2225
-- There seems to be no noticable difference in the number of chronic conditions based on whether the patient is < 65 or >= 65.

-- Question 5 

SELECT 
    n_chronic_conditions,
    FORMAT(AVG(MEDREIMB_IP + BENRES_IP + PPPYMT_IP + 
               MEDREIMB_OP + BENRES_OP + PPPYMT_OP + 
               MEDREIMB_CAR + BENRES_CAR + PPPYMT_CAR), 2) AS avg_spending
FROM (
    SELECT 
        (CASE WHEN SP_ALZHDMTA = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_CHF = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_CHRNKIDN = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_CNCR = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_COPD = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_DEPRESSN = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_DIABETES = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_ISCHMCHT = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_OSTEOPRS = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_RA_OA = 1 THEN 1 ELSE 0 END +
         CASE WHEN SP_STRKETIA = 1 THEN 1 ELSE 0 END) AS n_chronic_conditions,
        MEDREIMB_IP, BENRES_IP, PPPYMT_IP, 
        MEDREIMB_OP, BENRES_OP, PPPYMT_OP, 
        MEDREIMB_CAR, BENRES_CAR, PPPYMT_CAR
    FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
) subquery
GROUP BY n_chronic_conditions
ORDER BY n_chronic_conditions;

-- Answer
-- 0	273.15
-- 1	1,819.52
-- 2	2,909.39
-- 3	4,227.79
-- 4	6,482.80
-- 5	9,670.58
-- 6	14,544.12
-- 7	20,118.34
-- 8	27,010.23
-- 9	33,974.69
-- 10	41,860.03
-- 11	50,521.30

-- As the number of chronic conditions increases, the cost increases. This makes sense as it is more expensive to receive treatment for more issues.