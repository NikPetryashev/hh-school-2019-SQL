-- Задача 4
--В каком месяце было опубликовано больше всего резюме?
-- В каком месяце было опубликовано больше всего вакансий?
-- Вывести оба значения в одном запросе.
--EXPLAIN ANALYZE
WITH resul_res AS (
	SELECT date_trunc ('month',creation_time) AS month_resume, count(*)				
	FROM resumes
	GROUP BY date_trunc ('month',creation_time)
	), resul_vac AS (
	SELECT date_trunc ('month',creation_time) AS month_vacancy, count(*)				
	FROM vacancy
	GROUP BY date_trunc ('month',creation_time)
	) 
SELECT month_resume, count_resume, month_vacancy, count_vacancy
FROM (
	SELECT month_resume, count AS count_resume
	FROM resul_res
	WHERE count=(
		SELECT MAX(count)
		FROM resul_res)
	) AS resul_resume	
FULL OUTER JOIN (
	SELECT month_vacancy, count AS count_vacancy
	FROM resul_vac
	WHERE count=(
		SELECT MAX(count)
		FROM resul_vac)
	) AS resul_vacancy
ON true
LIMIT 1;