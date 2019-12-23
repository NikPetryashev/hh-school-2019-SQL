/* Задача 5
Вывести названия вакансий в алфавитном порядке, 
на которые было меньше 5 откликов за первую неделю после публикации вакансии.
В случае, если на вакансию не было ни одного отклика она также должна быть выведена. */
--EXPLAIN ANALYZE
SELECT vacansy_name
FROM (
	SELECT vac.vacancy_id, v_b.name AS vacansy_name
	FROM vacancy AS vac
	LEFT JOIN response AS resp
	ON vac.vacancy_id = resp.vacancy_id
		AND (resp.response_time-vac.creation_time) <= interval '7 day 00:00:00'		
	JOIN vacancy_body AS v_b
	ON v_b.vacancy_body_id=vac.vacancy_body_id
	GROUP BY vac.vacancy_id, vacansy_name 
	HAVING 	count(resp.response_id)<5) AS vac_resp	
ORDER BY vacansy_name ASC;


		
	