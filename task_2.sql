-----------------------------------------------------------
--заполняем таблицы тела вакансии
WITH vac_body AS (SELECT 
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 140 + i % 10)::integer)) AS company_name,

    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 90 + i % 10)::integer)) AS name,

    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 200 + i % 10)::integer)) AS text,

	CASE
		WHEN random() >= 0.3
		THEN 15000 + (random() * 150000)::int
		ELSE 0
	END AS compensation_from,
	
	(random() > 0.5) AS compensation_gross,
    (random() > 0.5) AS test_solution_required,
	
	(SELECT array_agg(cat.driver) FROM (SELECT DISTINCT substr('ABCDE', 1+(random() * 4)::integer,1) AS driver 
			FROM generate_series(1, ((random() * 5)::integer + i % 10) % 6)
			ORDER BY driver ASC) AS cat)
		AS driver_license_types	
FROM generate_series(1, 10000) AS g(i))

INSERT INTO vacancy_body(
    company_name, name, text, area_id, address_id, work_experience, 
    compensation_from, compensation_to, compensation_gross, test_solution_required,
    work_schedule_type, employment_type, driver_license_types 
)
SELECT
    vac_body.company_name AS company_name,
    vac_body.name AS name,
    vac_body.text AS text,    
    1+(random() * 500)::int AS area_id,
    1+(random() * 50000)::int AS address_id,
    (random() * 50)::int AS work_experience,
    vac_body.compensation_from AS compensation_from,
	
	CASE
		WHEN random() >= 0.5
		THEN CASE  
				WHEN vac_body.compensation_from > 0
				THEN 10000 + vac_body.compensation_from+(random() * 50000)::int
				ELSE 15000 + (random() * 150000)::int
			END
		ELSE 0
	END AS compensation_to,
	
	(random() > 0.5) AS compensation_gross,
    (random() > 0.5) AS test_solution_required,
    floor(random() * 5)::int AS work_schedule_type,
    floor(random() * 5)::int AS employment_type,
	vac_body.driver_license_types AS driver_license_types	
FROM vac_body;
-----------------------------------------------------------
--заполняем таблицу вакансий
WITH vac AS (SELECT    
    now()-(random() * 365 * 24 * 3600 * 5) * '1 second'::interval AS creation_time,-- random in last 5 years
	(SELECT vacancy_body_id FROM vacancy_body WHERE vacancy_body_id = i) AS vacancy_body_id
FROM generate_series(1, (SELECT count(vacancy_body_id) FROM vacancy_body)) AS g(i))

INSERT INTO vacancy (creation_time, expire_time, employer_id, disabled, visible,vacancy_body_id)
SELECT    
    vac.creation_time AS creation_time,-- random in last 5 years
    vac.creation_time+random()*(now()-vac.creation_time) AS expire_time,
    (random() * 10000)::int AS employer_id,
    (random() > 0.5) AS disabled,
    (random() > 0.5) AS visible,
    vac.vacancy_body_id AS vacancy_body_id
FROM vac;	
-----------------------------------------------------------
--заполняем таблицу специализаций
INSERT INTO specializations (name)
SELECT    
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 140 + i % 10)::integer)) AS name
FROM generate_series(1, 500) AS g(i);
-----------------------------------------------------------
--заполняем таблицу связи вакансий и специаизаций
INSERT INTO vacancy_body_specialization (vacancy_body_id, specialization_id)
SELECT DISTINCT
    1+(random() * (SELECT count(vacancy_body_id)-1 FROM vacancy_body))::int AS vacancy_body_id,
	1+(random() * (SELECT count(specialization_id)-1 FROM specializations))::int AS specialization_id
FROM generate_series(1, (SELECT count(vacancy_body_id) FROM vacancy_body)) AS g(i);	
-----------------------------------------------------------
--Заполняем таблицу соискателей
INSERT INTO users (gender_type, name, birthdate, education_type,
			driver_license_types, area_id, address_id, nationality_id, relocated, business_trip)
SELECT
	floor(random() * 2)::int AS gender_type,
	(SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 140 + i % 10)::integer)) AS name,
	now()-(random() * 365 * 60+365*15) * '1 day'::interval AS birthdate,
	floor(random() * 5)::int AS education_type,
	(SELECT array_agg(cat.driver) FROM 
		(SELECT DISTINCT substr('ABCDE', 1+(random() * 4)::integer,1) AS driver 
		FROM generate_series(1, ((random() * 5)::integer + i % 10) % 6)
		ORDER BY driver ASC) AS cat)	AS driver_license_types,
	1+(random() * 500)::int AS area_id,
	1+(random() * 50000)::int AS address_id,
	1+(random() * 150)::int AS nationality_id,	
    (random() > 0.5) AS relocated,
	(random() > 0.5) AS business_trip
FROM generate_series(1, 100000) AS g(i);
-----------------------------------------------------------
--заполняем таблицу резюме соискателей
WITH CTE AS (SELECT
    now()-(random() * 365 * 24 * 3600 * 5) * '1 second'::interval AS creation_time,-- random in last 5 years
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 200 + i % 10)::integer)) AS text,
	(SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 140 + i % 10)::integer)) AS title,
	(SELECT user_id FROM users WHERE user_id = i) AS user_id
	
FROM generate_series(1, (SELECT count(user_id) FROM users)) AS g(i))
INSERT INTO resumes(
    creation_time, expire_time, user_id, salary, 
	employment_type,work_schedule_type, work_experience, text, title
)
SELECT
    CTE.creation_time AS creation_time,-- random in last 5 years
    CTE.creation_time+random()*(now()-CTE.creation_time) AS expire_time,
	CTE.user_id AS user_id,
	15000 + (random() * 150000)::int AS salary,
	floor(random() * 5)::int AS employment_type,  
	floor(random() * 5)::int AS work_schedule_type,
	(random() * 50)::int AS work_experience,
	CTE.text AS text,
	CTE.title AS title	
FROM CTE;	

-----------------------------------------------------------
--заполняем таблицу связи резюме и специализаций
INSERT INTO resumes_specialization (resume_id, specialization_id)
SELECT DISTINCT
    1+(random() * (SELECT count(resume_id)-1 FROM resumes))::int AS resume_id,
	1+(random() * (SELECT count(specialization_id)-1 FROM specializations))::int AS specialization_id
FROM generate_series(1, (SELECT count(resume_id) FROM resumes)) AS g(i);

-----------------------------------------------------------
----заполняем таблицу ключевых навыков
INSERT INTO key_skills (skill)
SELECT
	(SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 140 + i % 10)::integer)) AS skill
FROM generate_series(1, 500) AS g(i);

--заполняем таблицу связи резюме и специаизаций
INSERT INTO resumes_key_skills (resume_id, skill_id)
SELECT DISTINCT
    1+(random() * (SELECT count(resume_id)-1 FROM resumes))::int AS resume_id,
	1+(random() * (SELECT count(skill_id)-1 FROM key_skills))::int AS skill_id
FROM generate_series(1, (SELECT count(resume_id) FROM resumes)) AS g(i);

-----------------------------------------------------------
----заполняем таблицу откликов
WITH CTE_resp AS (SELECT row_number() over(), vacancy_id, resume_id FROM 
		(SELECT DISTINCT
			1+(random() * (SELECT COUNT(vacancy_id)-1 FROM vacancy))::int AS vacancy_id,		
			1+(random() * (SELECT COUNT(resume_id)-1 FROM resumes))::int AS resume_id
		FROM generate_series(1, 101000)) AS t),	--запас, чтобы не было потом невалидных записей
	CTE_resp_valid AS (SELECT vacancy_id, vac_creation_time, vac_expire_time, resume_id, res_creation_time, res_expire_time FROM 
	(SELECT CTE_resp.row_number,CTE_resp.vacancy_id, vacancy.creation_time AS vac_creation_time, vacancy.expire_time AS vac_expire_time 
		FROM CTE_resp, vacancy WHERE CTE_resp.vacancy_id=vacancy.vacancy_id) AS vac_time
		JOIN 
	(SELECT CTE_resp.row_number, CTE_resp.resume_id, resumes.creation_time AS res_creation_time, resumes.expire_time AS res_expire_time 
		FROM CTE_resp, resumes WHERE CTE_resp.resume_id=resumes.resume_id) AS res_time 
		ON vac_time.row_number=res_time.row_number)

INSERT INTO response (vacancy_id, resume_id,response_time)
SELECT
    vacancy_id,		
	resume_id,	
	CASE
		WHEN (vac_expire_time BETWEEN res_creation_time AND res_expire_time)
			AND	(vac_creation_time BETWEEN res_creation_time AND res_expire_time)
			THEN vac_creation_time+(random() * (vac_expire_time-vac_creation_time))
		WHEN (res_creation_time BETWEEN vac_creation_time AND vac_expire_time)
			AND	(res_expire_time BETWEEN vac_creation_time AND vac_expire_time)
			THEN res_creation_time+(random() * (res_expire_time-res_creation_time))
		WHEN vac_expire_time BETWEEN res_creation_time AND res_expire_time
			THEN res_creation_time+(random() * (vac_expire_time-res_creation_time))
		WHEN vac_creation_time BETWEEN res_creation_time AND res_expire_time
			THEN vac_creation_time+(random() * (res_expire_time-vac_creation_time))
	END AS response_time
FROM CTE_resp_valid
WHERE ((vac_expire_time BETWEEN res_creation_time AND res_expire_time)
		AND	(vac_creation_time BETWEEN res_creation_time AND res_expire_time))
	OR ((res_creation_time BETWEEN vac_creation_time AND vac_expire_time)
		AND (res_expire_time BETWEEN vac_creation_time AND vac_expire_time))
	OR (vac_expire_time BETWEEN res_creation_time AND res_expire_time) 
	OR (vac_creation_time BETWEEN res_creation_time AND res_expire_time)
limit(50000);	
-----------------------------------------------------------

