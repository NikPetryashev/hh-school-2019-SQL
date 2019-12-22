/* ЗАДАЧА 8
Создаем новую таблицу для хранения всех изменений в таблице resumes
с использование триггера */

--DROP TABLE resume_change;

CREATE TABLE resume_change (
	resume_change_id serial PRIMARY KEY,
	resume_id integer DEFAULT 0 NOT NULL,
	last_change_time timestamp DEFAULT now() NOT NULL,
	json jsonb NOT NULL
);

--DROP FUNCTION change_resume() CASCADE;
CREATE FUNCTION change_resume() RETURNS TRIGGER AS $trig_change_resume$
BEGIN
	INSERT INTO
		resume_change(resume_id, last_change_time, json)
	VALUES
		(OLD.resume_id,	now(),
			row_to_json( OLD.*));

	IF NEW IS NULL
	THEN RETURN OLD;
	ELSE RETURN NEW;
	END IF;
END;

$trig_change_resume$ LANGUAGE plpgsql;

CREATE TRIGGER change_resume 
	BEFORE UPDATE OR DELETE ON resumes
	FOR EACH ROW
	EXECUTE PROCEDURE change_resume();


UPDATE resumes SET title='New title'
WHERE resume_id = 5 ;

--DELETE FROM resumes WHERE resume_id = 5 ;


SELECT resume_id, last_change_time, 
	json ->> 'title' AS old_title, 
	CASE 
		WHEN lead(json->>'title') OVER (PARTITION BY resume_id) IS NULL
			THEN (
				SELECT title 
				FROM resumes AS res 
				WHERE res.resume_id = res_ch.resume_id)
		ELSE lead(json->>'title') OVER (PARTITION BY resume_id) END 
		AS new_title
FROM resume_change AS res_ch
WHERE resume_id = 5
ORDER BY resume_id, last_change_time;