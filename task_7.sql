--индекс для 4 задачи
CREATE INDEX resumes_month_idx ON resumes(extract(month from creation_time));



--индекс для 3 задач
CREATE INDEX compensation_vac_idx ON vacancy_body (compensation_from, compensation_to)
	INCLUDE (compensation_gross);
--индекс для 5 задач
CREATE INDEX response_idx ON response(vacancy_id) INCLUDE(response_time);
--индекс для 6 задачи
CREATE INDEX resume_idx ON resumes(resume_id);