/*В своем проекте я хочу составить описание БД на примере веб-сайта ivi.ru.
Данный сервис предоставляет просмотр контента(фильмов, сериалов, мультфильмов...) по подписке.
Также, некоторый контент доступен "бесплатно", без регистрации пользователя и без оформления подписки, однако он очень ограничен.
При оформленной подписке, пользователи могут просматривать контент "по подписке", оформив "покупку", либо взять контент "в аренду".
Стоимость "аренды" и "покупки" контента также зависит от качества предоставляемого контента.
Стоимость подписки фиксируется в момент оформления.*/

DROP DATABASE IF EXISTS ivi;
CREATE DATABASE ivi;
USE ivi;

ALTER DATABASE `ivi`
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL, 
    firstname VARCHAR(50) DEFAULT NULL,
    lastname VARCHAR(50) DEFAULT NULL,
    email VARCHAR(120) DEFAULT NULL,
	phone BIGINT UNSIGNED UNIQUE NOT NULL,
	is_subscribed BIT(1) DEFAULT 0
) COMMENT 'Пользователи';

INSERT INTO users (id, firstname, lastname, email, phone, is_subscribed) VALUES 
('1', 'Reuben', 'Nienow', 'arlo50@example.org', '9374071116', 1),
('2', 'Frederik', 'Upton', 'terrence.cartwright@example.org', '9127498182', 1),
('3', 'Unique', 'Windler', 'rupert55@example.org', '9921090703', 0),
('4', 'Norene', 'West', 'rebekah29@example.net', '9592139196', 1),
('5', 'Frederick', 'Effertz', 'von.bridget@example.net', '9909791725', 1),
('6', 'Victoria', 'Medhurst', 'sstehr@example.net', '9456642385', 0),
('7', 'Austyn', 'Braun', 'itzel.beahan@example.com', '9448906606', 1),
('8', 'Jaida', 'Kilback', 'johnathan.wisozk@example.com', '9290679311', 0),
('9', 'Mireya', 'Orn', 'missouri87@example.org', '9228624339', 0),
('10', 'Jordyn', 'Jerde', 'edach@example.com', '9443126821', 1),
('11', 'Thad', 'McDermott', 'shaun.ferry@example.org', '9840726982', 1),
('12', 'Aiden', 'Runolfsdottir', 'doug57@example.net', '9260442904', 1),
('13', 'Bernadette', 'Haag', 'lhoeger@example.net', '9984574866', 1),
('14', 'Dedric', 'Stanton', 'tconsidine@example.org', '9499932439', 0),
('15', 'Clare', 'Wolff', 'effertz.laverna@example.org', '9251665331', 1),
('16', 'Lina', 'Macejkovic', 'smitham.demarcus@example.net', '9762021357', 0),
('17', 'Jerrell', 'Stanton', 'deja00@example.com', '9191103792', 1),
('18', 'Golden', 'Wisozk', 'frida19@example.com', '9331565437', 1),
('19', 'Elisa', 'Balistreri', 'romaine27@example.org', '9372983850', 0),
('20', 'Reed', 'Bogan', 'zhyatt@example.com', '9924753974', 0);

DROP TABLE IF EXISTS subscription_price;
CREATE TABLE subscription_price (
	id SERIAL,
    price DECIMAL (11,2) NOT NULL COMMENT 'Цена за подписку на указанный период',
    period TINYINT UNSIGNED NOT NULL COMMENT 'период подписки в месяцах'
    
) COMMENT 'Варианты цен на подписку';

INSERT INTO subscription_price (price, period) VALUES
('399', '1'),
('999', '3'),
('1790', '6'),
('2990', '12');

DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions ( 
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    subs_price_id BIGINT UNSIGNED NOT NULL ,
    created_at DATETIME DEFAULT NOW() COMMENT 'дата оформления подписки',
    extension BIT(1) COMMENT 'продление подписки (да, нет)',
    
    PRIMARY KEY (user_id, subs_price_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (subs_price_id) REFERENCES subscription_price(id)
) COMMENT 'Оформленные подписки пользователей';
/* Стоимость подписки у разных пользователей может быть разная за один и тот же период.
 * Например, если один пользователь оформил подписку год назад и стоимость за месяц у него 199 руб.,
 * то другой оформил сейчас и для него стоимость составляет 399 руб.
 */
INSERT INTO subscriptions (user_id, subs_price_id, extension) VALUES
('1', '1', 1),
('2', '2', 1),
('4', '1', 1),
('5', '4', 0),
('7', '1', 1),
('10', '3', 1),
('11', '1', 0),
('12', '2', 0),
('13', '1', 1),
('15', '4', 1),
('17', '4', 0),
('18', '2', 0);

DROP TABLE IF EXISTS origin_countries;
CREATE TABLE origin_countries (
	id SERIAL, 
	name VARCHAR(255) NOT NULL

) COMMENT 'Страны';

INSERT INTO `origin_countries` (`name`) VALUES
('Канада'),
('США'),
('Франция'),
('Великобритания'),
('Испания'),
('Австралия'),
('Россия'),
('Швеция'),
('Венгрия'),
('Германия'),
('Южная Корея'),
('Китай'),
('Норвегия'),
('Дания');

DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
	id SERIAL, 
	name VARCHAR(255) NOT NULL

) COMMENT 'Жанры';

INSERT INTO `genres` (`name`) VALUES
('Артхаус'),
('Военные'),
('Докмуентальные'),
('Драмы'),
('Криминал'),
('Триллеры'),
('Боевики'),
('Фэнтези'),
('Для всей семьи'),
('Комедии'),
('Мелодрамы'),
('Биография'),
('Приключения'),
('Ужасы'),
('Спорт'),
('Для детей'),
('Мистика'),
('Биография');

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL,
	name VARCHAR(255),
	is_serial BIT(1) DEFAULT 0,
	is_cartoon BIT(1) DEFAULT 0,
	filename VARCHAR (255) DEFAULT NULL COMMENT 'путь к файлу, который хранится на отдельном диске(сервере)',
	duration INT DEFAULT NULL COMMENT 'продолжительность фильма в минутах',
	metadata JSON COMMENT 'информация о файле, размер, расширение, дата создания, кодеки..', 
	release_year YEAR NOT NULL COMMENT 'год выпуска фильма в прокат',
	description TEXT,
	age_category TINYINT NOT NULL COMMENT 'возрастная категория фильмов от указанного количества лет',
	
	INDEX (name)
) COMMENT 'Медиа контент';

INSERT INTO media (name, is_serial, is_cartoon, filename, duration, metadata, release_year, description, age_category) VALUES 
('Отпетые мошенницы', 0, 0, 'a.avi', '89', NULL, 2019, 'Неудачливая мошенница Пенни учится разводить мужчин на миллионы, беря уроки обольщения у Жозефины.', 16),
('Домовой', 0, 0, 'a1.avi', '103', NULL, 2019, 'Молодая и независимая мама Вика с очаровательной дочкой Алиной и умным котом Кузей заселяются в странную квартиру.', 6),
('Теория большого взрыва', 1, 0, NULL, NULL, NULL, 2007, 'Легендарный, культовый, обожаемый миллионами, сериал Теория Большого Взрыва вот уже 10 лет остается самым популярным.', 16),
('Элементарно', 1, 0, NULL, NULL, NULL, 2012, 'Куратор по борьбе с наркоманией Джоан Ватсон приставлена наблюдателем к частному сыщику Шерлоку Холмсу.', 16),
('Холодное сердце', 0, 1, 'a4.avi', '98', NULL, 2013, 'Вечная, лютая, колкая стужа опустилась на далекую страну.', 0),
('Моана',  0, 1, 'a5.avi', '103', NULL, 2016, 'Две тысячи лет назад 14-ти летняя дочь вождя отправилась через Тихий океан в поисках легендарного острова.', 6),
('Йога дома', 1, 0, NULL, NULL, NULL, 2020, 'Йога дома', 12),
('Стретчинг', 1, 0, NULL, NULL, NULL, 2012, 'Стретчинг курс', 12),
('Дождливый день в Нью-Йорке', 0, 0, 'a9.avi', '88', NULL, 2017, 'Гэтсби едет в Нью-Йорк сос своей девушкой Эшли, которая должна взять интервью у известного режиссера.', 16),
('Гости', 0, 0, 'a9.avi', '83', NULL, 2005, 'Молодая компания проникает в заброшенную усадьбу у моря.', 16),
('Клиника', 1, 0, NULL, NULL, NULL, 2001, 'Культовый сериал про трудовые будни врачей американской клиники Святое Сердце.', 16),
('Гримм', 1, 0, NULL, NULL, NULL, 2011, 'Полицейский Ник живет обычной жизнью, но в один день представление Ника о мире координально меняется.', 16),
('Мстители', 0, 0, 'a12.avi', '137', NULL, 2012, 'Шестая по счету картина киновселенной Marvel.', 12),
('Тельма', 0, 0, 'a13.avi', '116', NULL, 2017, 'Тельма приезжает на учебу в Осло из маленького городка.', 18),
('Иллюзия любви', 0, 0, 'a14.avi', '115', NULL, 2016, 'Судьба жаждущей свободы женщины, которая ищет свою судьбу и идеал.', 12),
('Малышарики', 1, 1, NULL, NULL, NULL, 2015, 'Развивающий мультфильм для детей.', 0),
('Шерлок', 1, 0, 'a16.avi', NULL, NULL, 2010, 'Действие переносится в наши дни, Шерлок Холмс заносчив, гениален и асоциален.', 12),
('8 свиданий', 0, 0, 'a17.avi', '88', NULL, 2008, 'Мелодрама представляет собой 8 зарисовок из жизни разных людей.', 18);

DROP TABLE IF EXISTS series;
CREATE TABLE series (
	id SERIAL,
	media_id BIGINT UNSIGNED NOT NULL,
	season INT DEFAULT NULL COMMENT 'Номер сезона',
	series INT DEFAULT NULL COMMENT 'Номер серии',
	name VARCHAR(255) DEFAULT NULL COMMENT 'Название серии',
	description TEXT,
	duration INT DEFAULT NULL COMMENT 'продолжительность серии в минутах',
	release_year YEAR NOT NULL COMMENT 'год выпуска серии в прокат',
	filename VARCHAR (255) NOT NULL COMMENT 'путь к файлу, который хранится на отдельном диске(сервере)', 
	metadata JSON COMMENT 'информация о файле, размер, расширение, дата создания, кодеки..', 
	
	FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Серии к сериалам';

INSERT INTO series (media_id, season, series, name, description, duration, release_year, filename, metadata) VALUES 
('3','1', '1', 'Пилот', 'Пенни знакомится с друзьями-физиками Шелдоном и Леонардом. Они же представляют ее Раджу и Говарду.', '20', '2007', '1.avi', NULL),
('3','1', '2', 'Теория квартирного хаоса', 'Шелдон считает, что везде и во всем должен быть порядок. ', '19', '2007', '2.avi', NULL),
('4','1', '1', 'Пилот', 'Шерлок Холмс испытывает последствия психической травмы, он должен смириться со смертью любимой женщины. ', '40', '2012', '3.avi', NULL),
('4','1', '2', 'Пока ты спала', 'Шерлок Холмс и Джоан Ватсон помогают полиции Нью-Йорка. Капитан Грегсон верит в гений британского сыщика.', '40', '2012', '4.avi', NULL),
('7','1', '1', 'Занятие 1', 'Первое занятие', '20', '2018', '5.avi', NULL),
('8','1', '1', 'Занятие 1', 'Первое занятие', '20', '2018', '6.avi', NULL),
('11','1', '1', 'Мой первый день', 'Мой первый день', '21', '2001', '7.avi', NULL),
('11','1', '2', 'Мой первый день', 'После двух недель работы Джон Дориан все еще не чувствует себя полноправным членом команды докторов клиники.', '20', '2007', '8.avi', NULL),
('11','1', '3', 'Ошибка моего лучшего друга', 'С тех пор как Терк стал встречаться с Карлой, он стал гораздо меньше проводить времени с Джоном. ', '20', '2007', '9.avi', NULL),
('12','1', '1', 'Пилот', 'Ник Бёркхардт служит в полиции. Ему нужно расследовать загадочное происшествие.', '40', '2011', '10.avi', NULL),
('12','1', '2', 'Медвежья натура', 'Загадочные происшествия в городе, где служит детектив Ник Бёрнхардт и его напарник Хэнк Гриффин, продолжаются. ', '20', '2007', '11.avi', NULL),
('16','1', '1', 'Качели', 'Нюшенька и Барашик не хотят играть вместе. ', '4', '2015', '12.avi', NULL),
('16','1', '2', 'Прогулка', 'Крошик и Ёжик отправятся на прогулку на лодочке. А чтобы на неё попасть, нужна доска. ', '4', '2015', '13.avi', NULL),
('17','4', '1', 'Шесть Тэтчер', 'Приятного просмотра!', '40', '2010', '14.avi', NULL),
('17','4', '2', 'Шерлок при смерти', 'Приятного просмотра!', '40', '2010', '15.avi', NULL);

DROP TABLE IF EXISTS trailers;
CREATE TABLE trailers (
	ID SERIAL,
	media_id BIGINT UNSIGNED NOT NULL,
	name VARCHAR(255),
	filename VARCHAR (255) NOT NULL COMMENT 'путь к файлу, который хранится на отдельном диске(сервере)', 
	metadata JSON COMMENT 'информация о файле, размер, расширение, дата создания, кодеки..', 
	
	FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Трейлеры к фильмам';

INSERT INTO trailers (media_id, name, filename, metadata) VALUES
('1', 'Трейлер (дублированный)', '1.avi', NULL),
('1', 'Трейлер 2 (английский язык)', '2.avi', NULL),
('1', 'Трейлер (английский язык)', '3.avi', NULL),
('2', 'Трейлер (английский язык)', '4.avi', NULL),
('2', 'Трейлер (дублированный)', '5.avi', NULL),
('3', 'Трейлер (русский язык)', '6.avi', NULL),
('3', 'Трейлер (дублированный)', '7.avi', NULL),
('4', 'Трейлер', '8.avi', NULL),
('5', 'Трейлер (английский язык)', '9.avi', NULL),
('5', 'Трейлер', '10.avi', NULL),
('6', 'Трейлер', '11.avi', NULL),
('6', 'Трейлер 2', '12.avi', NULL),
('7', 'Трейлер', '13.avi', NULL),
('8', 'Трейлер', '14.avi', NULL),
('9', 'Трейлер (английский язык)', '15.avi', NULL),
('11', 'Трейлер (русский язык)', '16.avi', NULL),
('11', 'Трейлер (язык оригинала)', '17.avi', NULL),
('12', 'Трейлер (английский язык)', '18.avi', NULL),
('13', 'Трейлер', '19.avi', NULL),
('15', 'Трейлер', '20.avi', NULL);

DROP TABLE IF EXISTS media_genres;
CREATE TABLE media_genres (
	media_id BIGINT UNSIGNED NOT NULL,
	genres_id BIGINT UNSIGNED NOT NULL, 
	
	PRIMARY KEY (media_id, genres_id),
	FOREIGN KEY (genres_id) REFERENCES genres(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Жанры медиа';

INSERT INTO `media_genres` (media_id, genres_id) VALUES
(1, 10),
(2, 13),
(2, 4),
(2, 14),
(3, 11),
(3, 10),
(4, 17),
(4, 7),
(5, 10),
(5, 16),
(5, 18),
(6, 10),
(6, 13),
(6, 16),
(7, 15),
(8, 15),
(9, 11),
(10, 7),
(10, 14),
(11, 10),
(11, 11),
(12, 6),
(12, 7),
(12, 17),
(13, 8),
(13, 13),
(14, 5),
(14, 7),
(15, 4),
(15, 13),
(16, 16),
(17, 7),
(17, 17),
(18, 10),
(18, 11);

DROP TABLE IF EXISTS media_countries;
CREATE TABLE media_countries (
	media_id BIGINT UNSIGNED NOT NULL,
	countries_id BIGINT UNSIGNED NOT NULL, 
	
	PRIMARY KEY (countries_id, media_id),
	FOREIGN KEY (countries_id) REFERENCES origin_countries(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Страны производства медиа';

INSERT INTO media_countries (media_id, countries_id) VALUES
(1, 2),
(2, 7),
(3, 2),
(4, 4),
(5, 9),
(6, 13),
(7, 1),
(8, 10),
(9, 11),
(10, 6),
(11, 2),
(12, 6),
(13, 2),
(14, 13),
(15, 8),
(16, 7),
(17, 4),
(18, 8);

DROP TABLE IF EXISTS category_media_availability;
CREATE TABLE category_media_availability (
	id SERIAL, 
	category VARCHAR(255) -- название категории: подписка, бесплатно, покупка, аренда
) COMMENT 'Категории доступа медиа';

INSERT INTO category_media_availability (category) VALUES
('подписка'),
('бесплатно'),
('покупка и/или аренда');

DROP TABLE IF EXISTS media_category;
CREATE TABLE media_category (
	media_id BIGINT UNSIGNED NOT NULL, 
	category_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (category_id) REFERENCES category_media_availability(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Категории к медиа';

INSERT INTO media_category (media_id, category_id) VALUES
(1, 3),
(2, 1),
(3, 1),
(4, 3),
(5, 1),
(6, 3),
(7, 3),
(8, 3),
(9, 1),
(10, 1),
(11, 3),
(12, 1),
(13, 3),
(14, 1),
(15, 1),
(16, 3),
(17, 2),
(18, 2);

DROP TABLE IF EXISTS price_category;
CREATE TABLE price_category (
	id SERIAL, 
	purchase_sd DECIMAL (11,2) DEFAULT NULL COMMENT 'Цена за покупку в качестве sd',
	purchase_full_hd DECIMAL (11,2) DEFAULT NULL COMMENT 'Цена за покупку в качестве full_hd',
	purchase_4k DECIMAL (11,2) DEFAULT NULL COMMENT 'Цена за покупку в качестве 4k',
	rent_sd DECIMAL (11,2) DEFAULT NULL COMMENT 'Цена за аренду в качестве sd',
	rent_full_hd DECIMAL (11,2) DEFAULT NULL COMMENT 'Цена за аренду в качестве full_hd'
) COMMENT 'Категории цен';

INSERT INTO price_category (purchase_sd, purchase_full_hd, purchase_4k, rent_sd, rent_full_hd) VALUES
(299, 399, NULL, 99, 199),
(199, 299, NULL, NULL, NULL),
(NULL, NULL, 499, NULL, NULL),
(NULL, NULL, NULL, 199, 299);

DROP TABLE IF EXISTS media_price;
CREATE TABLE media_price (
	media_id BIGINT UNSIGNED NOT NULL, 
	price_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (price_id) REFERENCES price_category(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Цены на медиа в аренду или за покупку';

INSERT INTO media_price (media_id, price_id) VALUES
(1, 1),
(4, 4),
(6, 2),
(11, 3),
(13, 1),
(16, 2);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
	id SERIAL, 
	user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), 
        
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Комментарии пользователей';

INSERT INTO comments (user_id, media_id, body) VALUES
(1, 5, 'Прикольный мульт, посмотреть стоит.В отличном качестве вообще. А главное со смыслом.'),
(3, 5, 'Хороший всё-таки мультик. Песни - отличные.'),
(2, 2, 'Посмотрел пока только трейлер, после чего возникло желание.... взять и посмотреть весь фильм!'),
(4, 7, 'Рекомендую!'),
(2, 10, 'суперский фильм'),
(5, 17, 'Хорррошо))) Ненапряжный легкий фильм. Посмотерть пос ле рабоыт перед сном - самое оно)) Чтоб не забивать себе голову. '),
(7, 17, 'Классный фильм!'),
(3, 16, 'Прикольный мульт, посмотреть стоит.В отличном качестве вообще. А главное со смыслом.'),
(10, 12, 'Посмотерть пос ле рабоыт перед сном - самое оно'),
(2, 10, 'Рекомендую!'),
(13, 6, 'Фильм отличный, но смотреть его с подобным дубляжом песен просто издевательство.'),
(15, 6, 'Ненапряжный легкий фильм.'),
(16, 9, 'Фильм отличный понравился всей семье!'),
(16, 14, 'Рекомендую!'),
(19, 17, 'Сегодня смотрели в кинотеатре фильм. Очень рекомендую посмотреть на большом экране. Очень интересно и качественно сделано. '),
(16, 14, 'Рекомендую!'),
(16, 3, 'Сериал получился действительно отличным, жаль, что в 9-ом сезоне заменили персонажей, которые очень вошли в него.'),
(17, 3, 'Сериал шикарный, особенно хороши 1-6 сезоны, 7-8 в принципе тоже смотрибельны.'),
(19, 6, 'супер фильм!'),
(19, 13, 'плохо только то, что озвучка голосов очень тихая! и когда идёт перестрелка, драка, бомбёжка ну в общем война, то ничего не слышно что говорят');


DROP TABLE IF EXISTS category_filmmakers;
CREATE TABLE category_filmmakers (
	id SERIAL,
	category VARCHAR(255) NOT NULL,
	
	INDEX category_filmmakers(category)
) COMMENT 'Категории создателей фильмов';

INSERT INTO category_filmmakers (category) VALUES
('Режиссёр'),
('Актёры'),
('Продюсеры'),
('Оператор'),
('Сценаристы'),
('Композитор');

DROP TABLE IF EXISTS name_filmmakers;
CREATE TABLE name_filmmakers (
	id SERIAL,
	name VARCHAR(255) NOT NULL,
	filename VARCHAR (255) NOT NULL, -- путь к фото, которое хранится на отдельном диске(сервере)
	
    INDEX name_filmakers(name)
) COMMENT 'Фамилии создателей контента';

INSERT INTO name_filmmakers (name, filename) VALUES
('Эми Адамс', '1.jpeg'),
('Джейсон Айзекс', '1.jpeg'),
('Дженнифер Анистон', '1.jpeg'),
('Джерард Батлер', '1.jpeg'),
('Джош Бролин', '1.jpeg'),
('Стив Бушеми', '1.jpeg'),
('Дензел Вашингтон', '1.jpeg'),
('Сергей Гармаш', '1.jpeg'),
('Мел Гибсон', '1.jpeg'),
('Райан Гослинг', '1.jpeg'),
('Эмма Стоун', '1.jpeg'),
('Уилл Феррелл', '1.jpeg'),
('Джона Хилл', '1.jpeg'),
('Джессика Честейн', '1.jpeg'),
('Крис Эванс', '1.jpeg'),
('Филип Сеймур Хоффман', '1.jpeg'),
('Крис Хемсворт', '1.jpeg'),
('Энн Хэтуэй', '1.jpeg'),
('Ральф Файнс', '1.jpeg'),
('Вон Карвай', '1.jpeg'),
('Борис Барнет', '1.jpeg'),
('Дерек Джармен', '1.jpeg'),
('Марсель Карне', '1.jpeg'),
('Анри-Жорж Клузо', '1.jpeg'),
('Эмир Кустурица', '1.jpeg'),
('Фридрих Вильгельм Мурнау', '1.jpeg'),
('Нагиса Осима', '1.jpeg'),
('Годфри Реджо', '1.jpeg'),
('Ален Рене', '1.jpeg'),
('Карлос Саура', '1.jpeg'),
('Орсон Уэллс', '1.jpeg'),
('Хэл Хартли', '1.jpeg'),
('Миклош Янч', '1.jpeg'),
('Билли Уайлдер', '1.jpeg'),
('Итан и Джоэл Коэны', '1.jpeg'),
('Роберт Таун', '1.jpeg'),
('Фрэнсис Форд Коппола', '1.jpeg'),
('Уильям Голдман', '1.jpeg'),
('Чарли Кауфман', '1.jpeg'),
('Нора Эфрон', '1.jpeg'),
('Эрнест Леман', '1.jpeg'),
('Престон Стёрджес', '1.jpeg'),
('Фрэнсис Мэрион', '1.jpeg'),
('Джозеф Лео Манкевич', '1.jpeg'),
('Джозеф Лео Манкевич', '1.jpeg'),
('Альберт Брукс', '1.jpeg'),
('Нэнси Майерс', '1.jpeg'),
('Харольд Рэмис', '1.jpeg'),
('Мэттью Либатик', '1.jpeg'),
('Роберт Элсвит', '1.jpeg'),
('Уолли Пфистер', '1.jpeg'),
('Кристофер Леннерц', '1.jpeg'),
('Джеймс Ньютон Ховард', '1.jpeg');

DROP TABLE IF EXISTS filmmakers_info;
CREATE TABLE filmmakers_info (
	media_id BIGINT UNSIGNED NOT NULL,
	category_filmmakers_id BIGINT UNSIGNED NOT NULL,
	name_filmmakers_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (media_id, category_filmmakers_id, name_filmmakers_id),
    FOREIGN KEY (media_id) REFERENCES media(id),
    FOREIGN KEY (category_filmmakers_id) REFERENCES category_filmmakers(id),
    FOREIGN KEY (name_filmmakers_id) REFERENCES name_filmmakers(id)
) COMMENT 'Состав участников фильмов';

INSERT INTO filmmakers_info (media_id, category_filmmakers_id, name_filmmakers_id) VALUES
('1', '1', '50'),
('1', '2', '4'),
('1', '2', '5'),
('1', '2', '7'),
('1', '2', '8'),
('1', '3', '20'),
('1', '3', '27'),
('1', '4', '40'),
('1', '5', '17'),
('1', '6', '42'),
('2', '1', '43'),
('2', '2', '1'),
('2', '2', '4'),
('2', '2', '10'),
('2', '2', '9'),
('2', '3', '35'),
('2', '3', '21'),
('2', '4', '39'),
('2', '5', '40'),
('2', '6', '50'),
('3', '1', '37'),
('3', '2', '3'),
('3', '2', '7'),
('3', '2', '15'),
('3', '2', '16'),
('3', '3', '31'),
('3', '3', '27'),
('3', '4', '37'),
('3', '5', '40'),
('3', '6', '53'),
('4', '1', '31'),
('4', '2', '3'),
('4', '2', '7'),
('4', '2', '17'),
('4', '2', '20'),
('4', '3', '31'),
('4', '3', '27'),
('4', '4', '40'),
('4', '5', '38'),
('4', '6', '51'),
('5', '1', '47'),
('5', '2', '4'),
('5', '2', '8'),
('5', '2', '21'),
('5', '2', '11'),
('5', '3', '47'),
('5', '3', '45'),
('5', '4', '31'),
('5', '5', '39'),
('5', '6', '52'),
('6', '1', '51'),
('6', '2', '7'),
('6', '2', '11'),
('6', '2', '17'),
('6', '2', '19'),
('6', '3', '37'),
('6', '3', '31'),
('6', '4', '40'),
('6', '5', '35'),
('6', '6', '47'),
('7', '1', '37'),
('7', '2', '1'),
('7', '2', '3'),
('7', '2', '15'),
('7', '2', '8'),
('7', '3', '31'),
('7', '3', '27'),
('7', '4', '35'),
('7', '5', '44'),
('7', '6', '50'),
('8', '1', '39'),
('8', '2', '5'),
('8', '2', '7'),
('8', '2', '10'),
('8', '2', '18'),
('8', '3', '38'),
('8', '3', '49'),
('8', '4', '37'),
('8', '5', '35'),
('8', '6', '41'),
('9', '1', '41'),
('9', '2', '15'),
('9', '2', '9'),
('9', '2', '5'),
('9', '2', '17'),
('9', '3', '43'),
('9', '3', '22'),
('9', '4', '18'),
('9', '5', '37'),
('9', '6', '31'),
('10', '1', '39'),
('10', '2', '10'),
('10', '2', '15'),
('10', '2', '11'),
('10', '2', '9'),
('10', '3', '31'),
('10', '3', '39'),
('10', '4', '41'),
('10', '5', '47'),
('10', '6', '45'),
('11', '1', '20'),
('11', '2', '25'),
('11', '2', '35'),
('11', '2', '17'),
('11', '2', '14'),
('11', '3', '11'),
('11', '3', '9'),
('11', '4', '38'),
('11', '5', '27'),
('11', '6', '38'),
('12', '1', '5'),
('12', '2', '5'),
('12', '2', '7'),
('12', '2', '15'),
('12', '2', '11'),
('12', '3', '27'),
('12', '3', '18'),
('12', '4', '45'),
('12', '5', '42'),
('12', '6', '37'),
('13', '1', '51'),
('13', '2', '25'),
('13', '2', '17'),
('13', '2', '8'),
('13', '2', '9'),
('13', '3', '30'),
('13', '3', '18'),
('13', '4', '39'),
('13', '5', '27'),
('13', '6', '38'),
('14', '1', '13'),
('14', '2', '13'),
('14', '2', '7'),
('14', '2', '10'),
('14', '2', '15'),
('14', '3', '38'),
('14', '3', '35'),
('14', '4', '46'),
('14', '5', '49'),
('14', '6', '38'),
('15', '1', '48'),
('15', '2', '2'),
('15', '2', '18'),
('15', '2', '11'),
('15', '2', '14'),
('15', '3', '42'),
('15', '3', '37'),
('15', '4', '33'),
('15', '5', '29'),
('15', '6', '51');

DROP TABLE IF EXISTS users_purchased_films;
CREATE TABLE users_purchased_films (
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	is_viewed BIT(1) DEFAULT 0,
	
	PRIMARY KEY (user_id, media_id),
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT 'Купленные фильмы пользователей';

INSERT INTO users_purchased_films (user_id, media_id) VALUES
('1', '6'),
('1', '16'),
('2', '1'),
('2', '13'),
('2', '16'),
('5', '4'),
('7', '13'),
('7', '1'),
('8', '11'),
('11', '16'),
('11', '1'),
('12', '11'),
('12', '4'),
('15', '13'),
('15', '4'),
('16', '4'),
('18', '7'),
('19', '8'),
('20', '1'),
('20', '7');

DROP TABLE IF EXISTS media_rating;
CREATE TABLE media_rating (
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	directing TINYINT UNSIGNED DEFAULT NULL COMMENT 'оценка режиссуры',
	story TINYINT UNSIGNED DEFAULT NULL COMMENT 'сюжет',
	entertainment TINYINT UNSIGNED DEFAULT NULL COMMENT 'зрелищность',
	actors TINYINT UNSIGNED DEFAULT NULL COMMENT 'актеры',
	
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT 'Рейтинг медиа';

INSERT INTO media_rating (user_id, media_id, directing, story, entertainment, actors) VALUES
('1', '5', '7', '9', '5', '4'),
('1', '8', '8', '10', '3', '7'),
('3', '15', '6', '8', '2', '4'),
('4', '11', '8', '9', '8', '9'),
('4', '9', '5', '5', '5', '5'),
('5', '5', '7', '4', '6', '5'),
('7', '1', '10', '9', '10', '10'),
('9', '14', '4', '3', '3', '3'),
('9', '18', '5', '5', '5', '5'),
('10', '6', '7', '8', '9', '7'),
('13', '11', '2', '2', '3', '4'),
('13', '13', '9', '9', '9', '9'),
('16', '14', '4', '6', '4', '8'),
('17', '4', '8', '9', '8', '10'),
('17', '2', '3', '3', '2', '2'),
('17', '7', '5', '5', '5', '4'),
('19', '9', '10', '10', '10', '10'),
('20', '8', '5', '6', '7', '5'),
('18', '1', '7', '7', '8', '6'),
('19', '6', '8', '8', '8', '8');

DROP TABLE IF EXISTS watch_later;
CREATE TABLE watch_later (
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	is_viewed BIT DEFAULT 0 COMMENT 'Просмотрен ли фильм (да/нет)',
	
	PRIMARY KEY (user_id, media_id),
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT 'Смотреть позже';

INSERT INTO watch_later (user_id, media_id) VALUES
('1', '4'),
('1', '7'),
('1', '9'),
('2', '10'),
('2', '15'),
('2', '1'),
('5', '10'),
('5', '7'),
('5', '5'),
('8', '10'),
('8', '17'),
('8', '15'),
('11', '3'),
('11', '12'),
('15', '1'),
('15', '7'),
('17', '2'),
('17', '9'),
('20', '18'),
('20', '13');

DROP TABLE IF EXISTS watched_media;
CREATE TABLE watched_media (
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	start_watch_date DATETIME DEFAULT NOW(),
	
	PRIMARY KEY (user_id, media_id),
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT 'Просмотренные фильмы';

INSERT INTO watched_media (user_id, media_id) VALUES 
('1', '1'),
('1', '6'),
('1', '5'),
('2', '9'),
('2', '13'),
('2', '3'),
('5', '9'),
('5', '6'),
('5', '11'),
('8', '13'),
('8', '18'),
('8', '9'),
('11', '1'),
('11', '10'),
('15', '3'),
('15', '8'),
('17', '3'),
('17', '10'),
('20', '8'),
('20', '1');

DROP TABLE IF EXISTS rented_media;
CREATE TABLE rented_media (
	user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    rent_start DATETIME DEFAULT NOW() COMMENT 'Дата начала аренды',
    rent_end DATETIME AS (ADDDATE(rent_start, INTERVAL 2 DAY)) STORED COMMENT 'Дата окончания аренды (аренда дается на 2 дня)',
	is_viewed BIT DEFAULT 0 COMMENT 'Просмотрен ли фильм (да/нет)',
    
	PRIMARY KEY (user_id, media_id, rent_start),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT 'Фильмы, взятые в аренду';

INSERT INTO rented_media (user_id, media_id) VALUES 
('1', '7'),
('3', '1'),
('3', '8'),
('4', '4'),
('4', '8'),
('5', '1'),
('9', '16'),
('10', '13'),
('13', '7'),
('15', '7'),
('15', '8'),
('17', '6'),
('17', '4'),
('18', '13'),
('19', '11'),
('19', '13'),
('20', '4'),
('20', '6'),
('20', '8');

