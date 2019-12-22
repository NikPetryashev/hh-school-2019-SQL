/* Задача 3
Вывести среднюю величину предлагаемой зарплаты по каждому региону (area_id):
	средняя нижняя граница,
	средняя верхняя граница
	и средняя средних.
Нужно учесть поле compensation_gross, 
а также возможность отсутствия значения в обоих или одном из полей со значениями зарплаты. */
--EXPLAIN ANALYZE
WITH results_gross AS (
	(SELECT area_id,
		CASE 
			WHEN compensation_gross IS TRUE
				THEN compensation_from*0.87
			ELSE compensation_from
		END
		AS c_from,
		CASE 
			WHEN compensation_gross IS TRUE
				THEN compensation_to*0.87
			ELSE compensation_to
		END
		AS c_to
	FROM vacancy_body) 
)
SELECT res_area_id.area_id, avg_c_from, avg_c_to, avg_c_mid
FROM (
	SELECT area_id				--нужен, чтобы был весь набор area_id
	FROM vacancy_body
	GROUP BY area_id
	) AS res_area_id
LEFT JOIN (
	SELECT area_id, AVG(c_from) AS avg_c_from		--таблица с минимальными средними
	FROM results_gross
	WHERE  c_from>0
	GROUP BY area_id	
	) AS res_from
ON res_area_id.area_id=res_from.area_id		
LEFT JOIN (
	SELECT area_id, AVG(c_to) AS avg_c_to			--таблица с максильными средними
	FROM results_gross
	WHERE  c_to>0
	GROUP BY area_id
	) AS res_to
ON res_area_id.area_id=res_to.area_id			
LEFT JOIN (
	SELECT area_id, AVG((c_from+c_to)/2) AS avg_c_mid			--таблица со средними средними
	FROM results_gross
	WHERE 	c_from>0 AND c_to>0
	GROUP BY area_id
	) AS res_mid		
ON res_area_id.area_id=res_mid.area_id
ORDER BY res_area_id.area_id ASC;	