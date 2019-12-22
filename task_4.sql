/* В каком месяце было опубликовано больше всего резюме?
В каком месяце было опубликовано больше всего вакансий?
Вывести оба значения в одном запросе. */

--EXPLAIN ANALYZE
SELECT month_resume, month_vacancy
FROM (
	SELECT date_part ('month',creation_time) AS month_resume, count(*) AS count_resume 				
	FROM resumes
	GROUP BY month_resume
	ORDER BY count_resume DESC
	LIMIT 1
	) resul_res,	
	(SELECT date_part ('month',creation_time) AS month_vacancy, count(*) AS count_vacancy				
	FROM vacancy
	GROUP BY month_vacancy
	ORDER BY count_vacancy DESC
	LIMIT 1
	) AS resul_vac;
