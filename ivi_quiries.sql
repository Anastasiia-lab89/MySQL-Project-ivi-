
-- ----------------------------------------------6) Скрипты характерных выборок:-------------------------------------

-- Вывести фильмы, которые относятся к жанру "комедии" с указанием категории фильма(по подписке, бесплатно, покупка)
SELECT m.name, m.release_year, g.name, cma.category 
	FROM media m
		JOIN media_genres mg 
		JOIN genres g 
		JOIN category_media_availability cma 
		JOIN media_category mc 
			ON m.id = mg.media_id AND g.id = mg.genres_id AND cma.id = mc.category_id AND m.id = mc.media_id 
	WHERE g.name = 'Комедии';

-- Вывести рейтинг фильмов, доступных по подписке, по убыванию
SELECT m.name, cma.category, ROUND(AVG((directing + story + entertainment + actors )/4),1) AS rating, m.description 
	FROM media_rating mr
		JOIN media m 
		JOIN media_category mc 
		JOIN category_media_availability cma 
		ON m.id = mr.media_id AND m.id = mc.media_id AND mc.category_id = cma.id 
	WHERE cma.category = 'подписка'
	GROUP BY mr.media_id
	ORDER BY rating DESC;

-- Коллекции фильмов, например фильмы, в которых участвовал Джош Бролин
SELECT m.name, m.release_year, m.age_category, nf.name, cf.category 
	FROM media m
		JOIN filmmakers_info fi 
		JOIN name_filmmakers nf 
		JOIN category_filmmakers cf 
			ON m.id = fi.media_id AND nf.id = fi.name_filmmakers_id AND cf.id = fi.category_filmmakers_id 
	WHERE nf.name = 'Джош Бролин'
	ORDER BY m.release_year DESC;

-- раздел "Самое интересное":
-- Зарубежные сериалы (все страны, кроме России) с указанием серий и их описания.
SELECT m.name, s.season, s.season, s.name, oc.name, m.release_year 
	FROM media m
		JOIN series s 
		JOIN origin_countries oc 
		JOIN media_countries mc 
		ON m.id = s.media_id AND oc.id = mc.countries_id AND mc.media_id = m.id 
	WHERE 
		oc.name <> 'Россия'
	ORDER BY m.release_year DESC;

-- раздел "Самое интересное":
-- Мультcериалы для самых маленьких
SELECT m.name, s.season, s.series, s.name, s.description, s.duration 
	FROM media m
		JOIN series s
		ON m.id = s.media_id 
	WHERE is_serial = 1 AND is_cartoon = 1 AND age_category = 0;

-- ------------------------------------------------ 7) Представления:---------------------------------------------

-- Контент, доступный по подписке, отсортированный по дате выпуска
CREATE OR REPLACE VIEW subs AS
SELECT cma.category, m.name, m.release_year, m.description, m.age_category
	FROM media m
		JOIN media_category mc 
		JOIN category_media_availability cma 
		ON m.id = mc.media_id AND mc.category_id = cma.id 
	WHERE cma.category = 'подписка'
	ORDER BY m.release_year DESC;

SELECT * FROM subs;

/*Популярные сериалы на ivi (Выборка в произвольном порядке на основе наиболее часто просматриваемых сериалов 
и сериалов с высоким рейтингом):*/
CREATE OR REPLACE VIEW popular_serials(name) AS
	(SELECT m.name
		FROM media m
			JOIN watched_media wm
			ON m.id = wm.media_id
		WHERE m.is_serial = '1'
		GROUP BY m.name
		ORDER BY COUNT(*) DESC LIMIT 2) 
	UNION
	(SELECT m.name
		FROM media m
			JOIN media_rating mr 
			ON mr.media_id = m.id 
		WHERE m.is_serial = '1'
		GROUP BY m.name 
		ORDER BY ROUND(AVG((directing + story + entertainment + actors )/4),1) DESC LIMIT 3)
	ORDER BY RAND();

SELECT * FROM popular_serials;		

-- ------------------------------------------------ 8) Процедуры:---------------------------------------------

/*Процедура для добавления пользователя в таблицу subscriptions, 
если в таблице users ставится отметка is_subscribed = 1 при оформлении подписки*/
DROP PROCEDURE IF EXISTS sp_add_subs;
DELIMITER //
CREATE PROCEDURE sp_add_subs (IN new_user_id BIGINT, IN user_subs_price BIGINT, IN user_extension BIT(1))
BEGIN
	UPDATE users SET is_subscribed = 1 WHERE id = new_user_id ;
	INSERT INTO subscriptions (user_id, subs_price_id, extension) VALUES
		(new_user_id, user_subs_price, user_extension);
END//

DELIMITER ;

-- Проверяем процедуру. Добавляем 3-му пользователю флажок на оформление подписки, чтобы его данные добавились в таблицу subscriptions
CALL sp_add_subs('3', '1', 1);

SELECT * FROM users;
SELECT * FROM subscriptions;

/*Процедура для проверки продления подписки, если срок истек. Если стоит флажок на продление, то обновляется дата создания подписки.
Если флажок на продление не стоит, и срок подписки истек, то удаляется запись о пользователе из таблицы  subscriptions
и в таблице users.is_subscribed ставится флажок, что подписка отсутствует.*/

DROP PROCEDURE IF EXISTS sp_check_subs;
DELIMITER //
CREATE PROCEDURE sp_check_subs (IN new_user_id BIGINT)
BEGIN
	DECLARE res DATE;
	DECLARE is_extended BIT(1);
-- Присваиваем переменной res значение даты оформления подписки + период, 
-- на который оформлена подписка для конкретного пользователя
	SELECT (DATE(ADDDATE(s.created_at, INTERVAL sp.period MONTH))) INTO res
			FROM subscriptions s
				JOIN subscription_price sp
				ON sp.id = s.subs_price_id 
			WHERE s.user_id = new_user_id;
-- Присваиваем переменной is_extended значение поля extension для конкретного пользователя
	SELECT extension INTO is_extended FROM subscriptions WHERE user_id = new_user_id;

	IF (res <= DATE(NOW()) AND is_extended = 0) THEN -- проверяем, действует ли подписка на сегодняшний день и есть ли продление
		UPDATE users SET is_subscribed = 0 WHERE id = new_user_id;-- если условие выполняется, обновляем таблицу users
		DELETE FROM subscriptions WHERE user_id = new_user_id; -- и удаляем запись из таблицы subscriptions
	ELSEIF (res <= DATE(NOW()) AND is_extended = 1) THEN -- проверяем, действует ли подписка на сегодняшний день и есть ли продление
		UPDATE subscriptions SET created_at = res WHERE id = new_user_id ;-- если условие выполняется, меняем дату начала подписки(продление)
	END IF;
END//

DELIMITER ;
-- для проверки:
UPDATE subscriptions SET created_at = '2020-06-10 23:23:59.0' WHERE user_id = 1;
UPDATE subscriptions SET extension = 0 WHERE user_id = 1;

CALL sp_check_subs('1');
SELECT * FROM users WHERE id = 1;
SELECT * FROM subscriptions WHERE user_id = 1;

-- Процедура, которая делает подборку рекомендуемых фильмов

DROP PROCEDURE IF EXISTS sp_media_offers();
DELIMITER //
CREATE PROCEDURE sp_media_offers(for_user_id BIGINT)
BEGIN
	SELECT mg2.media_id -- подборка фильмов по жанру, который пользователь уже просматривал
	FROM media m 
	JOIN media_genres mg1
	JOIN media_genres mg2 
	JOIN watched_media wm 
	ON m.id = mg1.media_id AND m.id = wm.media_id AND mg1.genres_id = mg2.genres_id 
	WHERE wm.user_id = for_user_id AND wm.media_id <> mg2.media_id ;

END //
DELIMITER ;
CALL sp_media_offers('15')

-- ------------------------------------------------ 8) Триггеры:---------------------------------------------
/*Триггер, который после записи в таблицу "просмотренные медиа", проверяет, есть ли строчка с записью с таким же
user_id и media_id в таблицах ivi.watch_later, ivi.users_purchased_films, rented_media. если проверка выполняется,
ставится флажок is_viewed = 1.*/

DROP TRIGGER IF EXISTS tr_watched_media;
DELIMITER //
CREATE TRIGGER tr_watched_media AFTER INSERT ON watched_media
FOR EACH ROW
BEGIN
	IF EXISTS (SELECT * FROM watch_later WHERE user_id = NEW.user_id AND media_id = NEW.media_id) THEN 
		UPDATE watch_later SET is_viewed = 1 WHERE user_id = NEW.user_id AND media_id = NEW.media_id;
	END IF;
	IF EXISTS (SELECT * FROM users_purchased_films WHERE user_id = NEW.user_id AND media_id = NEW.media_id) THEN 
		UPDATE users_purchased_films SET is_viewed = 1 WHERE user_id = NEW.user_id AND media_id = NEW.media_id;
	END IF;
	IF EXISTS (SELECT * FROM rented_media WHERE user_id = NEW.user_id AND media_id = NEW.media_id) THEN 
		UPDATE rented_media SET is_viewed = 1 WHERE user_id = NEW.user_id AND media_id = NEW.media_id;
	END IF;
END//

DELIMITER ;
-- Для проверки
INSERT INTO watched_media (user_id, media_id) VALUES
('1', '4');
SELECT * FROM watch_later;
INSERT INTO watched_media (user_id, media_id) VALUES
('1', '16');
SELECT * FROM users_purchased_films;
INSERT INTO watched_media (user_id, media_id) VALUES
('1', '7');
SELECT * FROM users_purchased_films;
SELECT * FROM watch_later;
SELECT * FROM rented_media;
SELECT * FROM watched_media;отметка

-- ------------------------------------------------ 8) Функции:---------------------------------------------

-- Функция для подсчета рейтинга фильма на основе среднего из 4-х оценок

DROP FUNCTION IF EXISTS media_rating;
DELIMITER //
CREATE FUNCTION media_rating(directing INT, story INT, entertainment INT, actors INT)
RETURNS FLOAT(7,1)
BEGIN
	 
	RETURN ((directing + story + entertainment + actors )/4);
END //
DELIMITER ;
-- для проверки
SELECT media_rating('5', '7', '8', '7');


