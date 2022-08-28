-- Вывести 4 колонки: tasks.id, tasks.title, кол-во ракурсов и кол-во фото(все кроме ракурсов и инструкций) заданий типа "Снегопад. Содержание УЗ (1 день)" с 1-7 февраля текущего года. 
-- Поле sticker_id может содрежать значение null и его необходимо учитывать при формировании 4 колонки
-- Таблицы tasks и files необходимо заполнить самостоятельно для демонстрации результата.
-- Использовать в качестве СУБД postgresql

-- Таблица work_types
--id			title
--....
--100004027	Снегопад. Содержание УЗ (1 день)
--100004028	Снегопад. Содержание УЗ (2 день)
--100004029	Снегопад. Содержание УЗ (3 день)
--100003926	Промывка ТПУ и ПЗ
--...

-- Таблица stickers
--id	title
--1	ДО
--2	ПОСЛЕ
--3	Посев газона
--4	Ракурс
--5	Инструкция
--....

-- Таблица tasks
--id	title	work_type_id	date_created
--....

-- Таблица files
--id	task_id	sticker_id
--....


CREATE TABLE work_types (
  id INT GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(255),
  PRIMARY KEY(id)
);

CREATE TABLE stickers (
  id INT GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(255),
  PRIMARY KEY(id)
);

CREATE TABLE tasks (
  id INT GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(255),
  work_type_id INT,
  date_created DATE,
  PRIMARY KEY(id),
  CONSTRAINT fk_work_type
    FOREIGN KEY(work_type_id)
      REFERENCES work_types(id)
);

CREATE TABLE files (
  id INT GENERATED ALWAYS AS IDENTITY,
  task_id INT,
  sticker_id INT,
  PRIMARY KEY(id),
  CONSTRAINT fk_task
    FOREIGN KEY(task_id)
      REFERENCES tasks(id),
  CONSTRAINT fk_sticker
    FOREIGN KEY(sticker_id)
      REFERENCES stickers(id)
);

INSERT INTO work_types (title)
VALUES ('Снегопад. Содержание УЗ (1 день)'),
	   ('Снегопад. Содержание УЗ (2 день)'),
	   ('Снегопад. Содержание УЗ (3 день)'),
	   ('Промывка ТПУ и ПЗ');
	   
INSERT INTO stickers (title)
VALUES ('ДО'),
	   ('ПОСЛЕ'),
	   ('Посев газона'),
	   ('Ракурс'),
	   ('Инструкция');

INSERT INTO tasks (title, work_type_id, date_created)
VALUES ('Убрать территорию', 1, '2022-02-01'),
	   ('Подготовить рассаду', 2, '2022-02-02'),
	   ('Убрать снег', 3, '2022-02-03'),
	   ('Просеять семена', 4, '2022-02-04'),
	   ('Полить грядки', 3, '2022-02-05'),
	   ('Купить стройматериалы', 2, '2022-02-06'),
	   ('Купить горшки для цветов', 1, '2022-02-09');
	   
INSERT INTO files (task_id, sticker_id)
VALUES (1, 1),
	   (2, 3),
	   (3, NULL),
	   (4, 2),
	   (5, 4),
	   (6, NULL),
	   (7, 1),
	   (2, 4),
	   (2, 3),
	   (4, 3),
	   (3, NULL),
	   (2, 2),
	   (5, NULL),
	   (6, 4),
	   (5, 4),
	   (2, 5),
	   (4, 3),
	   (3, NULL),
	   (1, 2),
	   (5, 5),
	   (6, 4),
	   (3, NULL),
	   (6, 3);

SELECT TK.id
	 , TK.title
	 , SUM(CASE WHEN ST.title = 'Ракурс' THEN 1 
		   							     ELSE 0
		    END) AS R_NUM
	 , SUM(CASE WHEN ST.title IN('Ракурс', 'Инструкция') THEN 0
		  		WHEN ST.title IS NULL                    THEN 0
		  												 ELSE 1
		  	END) AS F_NUM
  FROM tasks AS TK
  JOIN work_types AS WT
    ON TK.work_type_id = WT.id 
       AND WT.title LIKE 'Снегопад. Содержание УЗ (% день)'
	   AND date_created BETWEEN DATE_TRUNC('YEAR', CURRENT_DATE) + interval '1 month' 
				   	        AND DATE_TRUNC('YEAR', CURRENT_DATE) + interval '1 month 6 days'
  LEFT JOIN files AS FL
         ON TK.id = FL.task_id
  LEFT JOIN stickers AS ST
         ON FL.sticker_id = ST.id
GROUP BY TK.id, TK.title
ORDER BY TK.id, TK.title;