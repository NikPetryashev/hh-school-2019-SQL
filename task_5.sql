/* Задача 5
Вывести названия вакансий в алфавитном порядке, 
на которые было меньше 5 откликов за первую неделю после публикации вакансии.
В случае, если на вакансию не было ни одного отклика она также должна быть выведена. */
--CREATE INDEX response_idx ON response(vacancy_id) INCLUDE(response_time);
--CREATE INDEX vacancy_idx ON vacancy(vacancy_id) INCLUDE(creation_time);
--EXPLAIN ANALYZE
WITH result_response AS( --формируем таблицу с id вакансий и счетчиком откликов за неделю 
	SELECT vac.vacancy_id,count(vac.vacancy_id) AS count	
	FROM vacancy AS vac
    JOIN response AS resp
    ON vac.vacancy_id = resp.vacancy_id
		AND (resp.response_time-vac.creation_time) <= interval '7 day 00:00:00'
	GROUP BY vac.vacancy_id),
    vac_name AS ( --формируем таблицу с id вакансий и ее именем
	SELECT vb.name, vac.vacancy_id
	FROM vacancy_body AS vb
	JOIN vacancy AS vac
	ON vb.vacancy_body_id=vac.vacancy_body_id
	)   
SELECT v_n.name AS vacansy_name 
FROM vac_name AS v_n, result_response AS res
WHERE v_n.vacancy_id=res.vacancy_id 
AND res.count<5
UNION(
	SELECT vn.name
	FROM vac_name AS vn
	WHERE NOT EXISTS (
		SELECT *
		FROM response AS res
		WHERE vn.vacancy_id = res.vacancy_id
		))
ORDER BY vacansy_name ASC;








		
	