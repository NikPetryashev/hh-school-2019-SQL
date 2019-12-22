/* Задача 6
Для каждого резюме вывести его идентификатор, массив из его специализаций,
а также самую частую специализацию у вакансий, на которые он откликался 
(NULL если он не откликался ни на одну вакансию).
Для агрегации специализаций в массив воспользоваться функцией array_agg. */ 
--EXPLAIN ANALYZE
WITH res_id_res_spec_arr AS( --таблица с id резюме и его специализациями
    SELECT resumes.resume_id AS res_id, array_agg(r_s.specialization_id) AS res_arr_spec
	FROM resumes
    LEFT JOIN resumes_specialization AS r_s
	ON  resumes.resume_id = r_s.resume_id 
	GROUP BY res_id),
  
	add_vac_id AS (	--добавим в выборку id ваканий, которые откликались на резюме
	SELECT res_id, res_arr_spec, resp.vacancy_id AS vac_id
	FROM res_id_res_spec_arr
    LEFT JOIN response AS resp
	ON res_id_res_spec_arr.res_id = resp.resume_id ),
	   
	add_vac_body_id AS (	--добавим в выборку id тела вакансий
	SELECT res_id, res_arr_spec, vac_id, vac.vacancy_body_id AS vac_b_id 
	FROM add_vac_id
	LEFT JOIN vacancy AS vac 
	ON vac_id = vac.vacancy_id),

	add_count_vac_b_spec AS ( --добавим специализаций у вакансий и их количетсво
	SELECT res_id, res_arr_spec, count(vac_b_spec.specialization_id) AS count, vac_b_spec.specialization_id AS spec
	FROM add_vac_body_id
	LEFT JOIN vacancy_body_specialization AS vac_b_spec
	ON vac_b_spec.vacancy_body_id = vac_b_id
	GROUP BY res_id, res_arr_spec, spec
	ORDER BY res_id),

	max_count_v_spec AS ( --выбор максимальной специализации у вакансии
	SELECT res_id, res_arr_spec, max(count) AS max_count
	FROM add_count_vac_b_spec
	GROUP BY res_id, res_arr_spec
)
SELECT DISTINCT ON (max_count_v_spec.res_id) max_count_v_spec.res_id, max_count_v_spec.res_arr_spec, add_count_vac_b_spec.spec
FROM max_count_v_spec
JOIN add_count_vac_b_spec
ON max_count_v_spec.res_id = add_count_vac_b_spec.res_id
	AND max_count = add_count_vac_b_spec.count
ORDER BY res_id;