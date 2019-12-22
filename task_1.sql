--таблица наполнения вакансии
CREATE TABLE vacancy_body (
    vacancy_body_id serial PRIMARY KEY,							--уникальный номер
    company_name varchar(150) DEFAULT ''::varchar NOT NULL,		--названии компании
    name varchar(100) DEFAULT ''::varchar NOT NULL,				--имя вакансии
    text text,													--общее описание
    area_id integer DEFAULT 0 NOT NULL,									--id региона 
    address_id integer DEFAULT 0 NOT NULL,								--id адреса поиска
    work_experience integer DEFAULT 0 NOT NULL,					--требуемый опыт
    compensation_from bigint DEFAULT 0,							--минимальная ЗП
    compensation_to bigint DEFAULT 0,							--максимальная ЗП
	compensation_gross boolean,									--налог включен/выключен
    test_solution_required boolean DEFAULT false NOT NULL,		--
    work_schedule_type integer DEFAULT 0 NOT NULL,				--тип графика работы
    employment_type integer DEFAULT 0 NOT NULL,    				--тип занятости
    driver_license_types varchar(5)[],							--тип лицензии
    CONSTRAINT vacancy_body_work_employment_type_validate CHECK ((employment_type = ANY (ARRAY[0, 1, 2, 3, 4]))),
    CONSTRAINT vacancy_body_work_schedule_type_validate CHECK ((work_schedule_type = ANY (ARRAY[0, 1, 2, 3, 4])))
);

--таблица вакансий
CREATE TABLE vacancy (
    vacancy_id serial PRIMARY KEY,								--уникальный номер
    creation_time timestamp NOT NULL,							--время создания вакансии
    expire_time timestamp NOT NULL,								--время закрытия
    employer_id integer DEFAULT 0 NOT NULL,  					--№ компании  
    disabled boolean DEFAULT false NOT NULL,					--открыта/закрыта
    visible boolean DEFAULT true NOT NULL,						--
    vacancy_body_id integer DEFAULT 0 NOT NULL REFERENCES vacancy_body(vacancy_body_id)	--ссылка на тело вакансии
);

--таблица специализаций
CREATE TABLE specializations (
    specialization_id serial PRIMARY KEY,					--уникальной номер специализации
	name varchar(150) DEFAULT ''::varchar NOT NULL			--описание
);

--таблица связи вакансии и специализации
CREATE TABLE vacancy_body_specialization (
    vacancy_body_id integer DEFAULT 0 NOT NULL,					--уникальной номер описания вакансии
    specialization_id integer DEFAULT 0 NOT NULL,
	FOREIGN KEY (vacancy_body_id) REFERENCES vacancy_body(vacancy_body_id) ON DELETE CASCADE, --уникальной номер вакансии
	FOREIGN KEY (specialization_id) REFERENCES specializations(specialization_id) ON DELETE CASCADE --уникальной номер специализации
);

--таблица соискателей
--CREATE TYPE gender AS ENUM ('M','L');
CREATE TABLE users (
	user_id serial PRIMARY KEY,									--уникальной номер пользователя
	gender_type integer DEFAULT 0 NOT NULL,						--пол
	name varchar(150) DEFAULT ''::varchar NOT NULL,				--имя
	birthdate date NOT NULL,									--дата рождения
	education_type integer DEFAULT 0 NOT NULL,					--тип образования
	driver_license_types varchar(5)[],
	area_id integer DEFAULT 0 NOT NULL,							--№ региона
    address_id integer DEFAULT 0 NOT NULL,						--№ адреса
	nationality_id	integer DEFAULT 0 NOT NULL,					--гражданство
	relocated boolean DEFAULT false NOT NULL,					--готовность к переезду
	business_trip boolean DEFAULT false NOT NULL,				--готовность к командировкам
	CONSTRAINT users_gender_type_validate CHECK ((gender_type = ANY (ARRAY[0, 1]))),	
	CONSTRAINT users_education_type_validate CHECK ((education_type = ANY (ARRAY[0, 1, 2, 3, 4])))
);

--таблица резюме соискателей
CREATE TABLE resumes (
	resume_id serial PRIMARY KEY,								--уникальной номер резюме
	creation_time timestamp NOT NULL,							--время создания резюме
    expire_time timestamp NOT NULL,								--
	user_id integer DEFAULT 0 NOT NULL,							--уникальной номер пользователя	
	salary bigint DEFAULT 0,									--уровень зарплаты
	employment_type integer DEFAULT 0 NOT NULL,					--тип занятости
	work_schedule_type integer DEFAULT 0 NOT NULL,				--тип графика работы
	work_experience integer DEFAULT 0 NOT NULL,					--стаж
	text text,													--общее поле текст

	title varchar(150) DEFAULT ''::varchar NOT NULL,
	
	CONSTRAINT resumes_work_employment_type_validate CHECK ((employment_type = ANY (ARRAY[0, 1, 2, 3, 4]))),
	CONSTRAINT resumes_work_schedule_type_validate CHECK ((work_schedule_type = ANY (ARRAY[0, 1, 2, 3, 4]))),
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

--таблица откликов (связь резюме и вакансии)
CREATE TABLE response (
	response_id serial PRIMARY KEY,
    vacancy_id integer DEFAULT 0 NOT NULL,					--уникальной номер вакансий
    resume_id integer DEFAULT 0 NOT NULL,					--уникальной номер резюме
	response_time timestamp DEFAULT now() NOT NULL,						--время отклика
	FOREIGN KEY (vacancy_id) REFERENCES vacancy(vacancy_id) ON DELETE CASCADE, --уникальной номер вакансии
	FOREIGN KEY (resume_id) REFERENCES resumes(resume_id) ON DELETE CASCADE 
);

--таблица связи резюме и специализации
CREATE TABLE resumes_specialization (
    resume_id integer DEFAULT 0 NOT NULL,				--уникальной номер описания резюме
    specialization_id integer DEFAULT 0 NOT NULL,		--уникальной номер специализации);
	FOREIGN KEY (resume_id) REFERENCES resumes(resume_id) ON DELETE CASCADE,
	FOREIGN KEY (specialization_id) REFERENCES specializations(specialization_id) ON DELETE CASCADE 
);
--таблица ключевых навыков
CREATE TABLE key_skills (
    skill_id serial PRIMARY KEY,						--уникальной номер навыка
	skill varchar(150) DEFAULT ''::varchar NOT NULL		--название навыка		
);
--таблицы связи соискателя и его навыков
CREATE TABLE resumes_key_skills (
    resume_id integer DEFAULT 0 NOT NULL,					--уникальной номер резюме
    skill_id integer DEFAULT 0 NOT NULL,				--уникальной номер навыка
	FOREIGN KEY (skill_id) REFERENCES key_skills(skill_id) ON DELETE CASCADE, 
	FOREIGN KEY (resume_id) REFERENCES resumes(resume_id) ON DELETE CASCADE 
);


