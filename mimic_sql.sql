-- Query:1
SELECT discharge_location, count(mimic.mimiciii.patients.SUBJECT_ID)
FROM mimic.mimiciii.patients
INNER JOIN mimic.mimiciii.admissions
ON mimic.mimiciii.patients.subject_id = mimic.mimiciii.admissions.subject_id
WHERE ethnicity LIKE 'WHITE' and insurance = 'Medicare' and admission_type = 'EMERGENCY'
GROUP BY discharge_location;

-- Query:2
SELECT 
    CAST(SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS FLOAT) /
    NULLIF(SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END), 0) 
AS male_to_female_ratio
FROM mimic.mimiciii.patients
INNER JOIN mimic.mimiciii.prescriptions
ON mimic.mimiciii.patients.subject_id = mimic.mimiciii.prescriptions.subject_id
WHERE drug_type = 'MAIN';

-- Query:3
SELECT insurance, count(mimic.mimiciii.patients.SUBJECT_ID)
FROM mimic.mimiciii.patients
INNER JOIN mimic.mimiciii.admissions
ON mimic.mimiciii.patients.subject_id = mimic.mimiciii.admissions.subject_id
INNER JOIN mimic.mimiciii.prescriptions
ON mimic.mimiciii.admissions.subject_id = mimic.mimiciii.prescriptions.subject_id
WHERE drug_type = 'ADDITIVE'
GROUP BY insurance;

-- Query:4
SELECT 
  CASE 
    WHEN ROUND(EXTRACT(EPOCH FROM (admittime - dob)) / (365.25 * 24 * 3600)) < 18 THEN '0-17'
    WHEN ROUND(EXTRACT(EPOCH FROM (admittime - dob)) / (365.25 * 24 * 3600)) BETWEEN 18 AND 40 THEN '18-40'
    WHEN ROUND(EXTRACT(EPOCH FROM (admittime - dob)) / (365.25 * 24 * 3600)) BETWEEN 41 AND 65 THEN '41-65'
    ELSE '65+'
  END AS age_group,
  COUNT(*) AS patient_count
FROM mimic.mimiciii.patients
INNER JOIN mimic.mimiciii.admissions 
ON mimic.mimiciii.patients.subject_id = mimic.mimiciii.admissions.subject_id
WHERE diagnosis LIKE 'CONGESTIVE HEART FAILURE'
GROUP BY age_group
ORDER BY patient_count DESC;

-- Query:5
SELECT 
  COUNT(CASE WHEN hospital_expire_flag = 1 THEN 1 END) * 100.0 / COUNT(*) AS mortality_rate
FROM mimic.mimiciii.admissions
WHERE diagnosis LIKE 'CONGESTIVE HEART FAILURE';

-- Query:6
SELECT icustays.first_careunit, COUNT(*) AS admission_count
FROM mimic.mimiciii.icustays
INNER JOIN mimic.mimiciii.admissions 
ON icustays.hadm_id = admissions.hadm_id
WHERE admissions.diagnosis LIKE 'CONGESTIVE HEART FAILURE'
GROUP BY icustays.first_careunit
ORDER BY admission_count DESC;

-- Query:7
SELECT drug,  COUNT(*) AS prescription_count
FROM mimic.mimiciii.prescriptions
INNER JOIN mimic.mimiciii.admissions 
ON mimic.mimiciii.prescriptions.hadm_id = mimic.mimiciii.admissions.hadm_id
WHERE diagnosis LIKE 'CONGESTIVE HEART FAILURE'
GROUP BY drug
ORDER BY prescription_count DESC
LIMIT 10;

-- Query:8
SELECT diagnoses_icd.icd9_code, d_icd_diagnoses.long_title, COUNT(*) AS comorbidity_count
FROM mimic.mimiciii.diagnoses_icd
INNER JOIN mimic.mimiciii.admissions 
ON diagnoses_icd.hadm_id = admissions.hadm_id
INNER JOIN mimic.mimiciii.d_icd_diagnoses 
ON diagnoses_icd.icd9_code = d_icd_diagnoses.icd9_code
WHERE admissions.diagnosis LIKE 'CONGESTIVE HEART FAILURE'
AND diagnoses_icd.icd9_code != '428.0'
GROUP BY diagnoses_icd.icd9_code, d_icd_diagnoses.long_title
ORDER BY comorbidity_count DESC
LIMIT 10;

-- Query:9
SELECT d_labitems.itemid, d_labitems.label, COUNT(*) AS test_count
FROM mimic.mimiciii.labevents
INNER JOIN mimic.mimiciii.admissions 
ON mimic.mimiciii.labevents.hadm_id = mimic.mimiciii.admissions.hadm_id
INNER JOIN mimic.mimiciii.d_labitems 
ON mimic.mimiciii.labevents.itemid = mimic.mimiciii.d_labitems.itemid
WHERE diagnosis LIKE 'CONGESTIVE HEART FAILURE'
GROUP BY d_labitems.itemid, d_labitems.label
ORDER BY test_count DESC
LIMIT 10;

-- Query:10
SELECT labevents.itemid, d_labitems.label, AVG(valuenum) AS avg_value, MIN(valuenum) 
AS min_value, MAX(valuenum) AS max_value
FROM mimic.mimiciii.labevents 
INNER JOIN mimic.mimiciii.admissions 
ON labevents.hadm_id = admissions.hadm_id 
INNER JOIN mimic.mimiciii.d_labitems 
ON labevents.itemid = d_labitems.itemid 
WHERE admissions.diagnosis LIKE 'CONGESTIVE HEART FAILURE'
AND valuenum IS NOT NULL 
GROUP BY labevents.itemid, d_labitems.label 
ORDER BY avg_value DESC LIMIT 10;
