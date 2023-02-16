DROP DATABASE IF EXISTS perekrestok;
CREATE DATABASE perekrestok; 
USE perekrestok;


DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles(
id SERIAL PRIMARY KEY, 
    firstname VARCHAR(100),
    lastname VARCHAR(100),
    birthday DATE,
    email VARCHAR(100) UNIQUE,
    password_hash varchar(100),
    phone BIGINT,
    is_deleted bit default 0,
    INDEX phone_idx(phone)  
);

DROP TABLE IF EXISTS delivery_zone;
CREATE TABLE delivery_zone (
id SERIAL PRIMARY KEY,
zone_name VARCHAR(20) 
);

DROP TABLE IF EXISTS adress;
CREATE TABLE adress(
id SERIAL PRIMARY KEY,
profiles_id BIGINT UNSIGNED NOT NULL,
adress VARCHAR(100),
delivery_zone_id BIGINT UNSIGNED NOT NULL,
FOREIGN KEY (profiles_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (delivery_zone_id) REFERENCES delivery_zone(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS warehouse; 
CREATE TABLE warehouse (
id SERIAL PRIMARY KEY,
location VARCHAR(100),
delivery_zone_id BIGINT UNSIGNED NOT NULL ,
FOREIGN KEY (delivery_zone_id) REFERENCES delivery_zone(id) ON UPDATE CASCADE ON DELETE CASCADE
);



DROP TABLE IF EXISTS loyalty_card;
CREATE TABLE loyalty_card (
id SERIAL PRIMARY KEY,
profiles_id BIGINT UNSIGNED NOT NULL,
balance INT UNSIGNED,
FOREIGN KEY (profiles_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE
);


DROP TABLE IF EXISTS products ;
CREATE TABLE products(
id SERIAL PRIMARY KEY,
name VARCHAR(100),
price FLOAT UNSIGNED,
category VARCHAR(100),
image VARCHAR(200),
description VARCHAR(200)
);

DROP TABLE IF EXISTS discount  ;
CREATE TABLE discount (
id SERIAL PRIMARY KEY,
discount_name VARCHAR(100),
discount_size FLOAT UNSIGNED,
products_id BIGINT UNSIGNED,
FOREIGN KEY (products_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE
);


DROP TABLE IF EXISTS orders_s;
CREATE TABLE orders_s(
id SERIAL PRIMARY KEY,
profiles_id BIGINT UNSIGNED,
order_price FLOAT UNSIGNED, 
order_status VARCHAR(30),
id_warehouse BIGINT UNSIGNED,  
order_day DATETIME DEFAULT NOW(),
loyalty_card_id BIGINT UNSIGNED,
FOREIGN KEY (profiles_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (id_warehouse) REFERENCES warehouse(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (loyalty_card_id) REFERENCES loyalty_card(id) ON UPDATE CASCADE ON DELETE CASCADE

);


DROP TABLE IF EXISTS orders_details ;
CREATE TABLE orders_details (
-- id SERIAL PRIMARY KEY,
orders_s_id BIGINT UNSIGNED,
products_id BIGINT UNSIGNED,
quantity FLOAT UNSIGNED, 
discount_id BIGINT UNSIGNED,
PRIMARY KEY(orders_s_id, products_id),
FOREIGN KEY (orders_s_id) REFERENCES orders_s(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (products_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (discount_id) REFERENCES discount(id) ON UPDATE CASCADE ON DELETE CASCADE
);


DROP TABLE IF EXISTS basket  ;
CREATE TABLE basket(
profiles_id BIGINT UNSIGNED,
products_id BIGINT UNSIGNED,
PRIMARY KEY(profiles_id, products_id),
FOREIGN KEY (profiles_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (products_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE
) ;



DROP TABLE IF EXISTS payment  ;
CREATE TABLE payment(
id SERIAL PRIMARY KEY,
orders_s_id BIGINT UNSIGNED,
status VARCHAR(30),
summ FLOAT UNSIGNED,
payment_type CHAR(1), -- оплата банковской картой-1, оплата баллами лояльности-2
FOREIGN KEY (orders_s_id) REFERENCES orders_s(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS transactions_accrual;
CREATE TABLE transactions_accrual ( 
orders_s_id BIGINT UNSIGNED PRIMARY KEY, 
points_sum BIGINT UNSIGNED,
FOREIGN KEY (orders_s_id) REFERENCES orders_s(id) ON UPDATE CASCADE ON DELETE CASCADE
);



INSERT INTO profiles (firstname, lastname, birthday, email, password_hash, phone, is_deleted)
VALUES
 ('Саша', 'Гавриков', '1987.11.12', 'devin56@example.net', '063d61d19563e8b8d8b2e34b2852e22ace42dbee', 9247483547, 1),
 ('Егор', 'Иванов', '1989.06.12', 'wilfred.bernier@example.org', '5aec7b36870c757a92cc84740070c8cfebd3d5e9', 9144433647, 1),
 ('Степа', 'Печкин', '1990.01.02', 'eunice64@example.com', 'f52476d2eaf049c456ce74923ab87ccac738e679', 9147483647, 0),
 ('Петя', 'Степанов', '2000.05.11', 'kathryne87@example.com', '7f52e5672d76492ddcccce0ada03a76a06ddd006', 9997483647, 0),
 ('Вася', 'Содоров', '2002.05.23', 'haley.alene@example.com', 'fed0823485b8e0a19bf50fbea4b75225b00835d5', 9847783647, 1),
 (' Женя', ' Петров', '1987.11.12', 'okuneva.kayli@example.com', 'bfc15b64a8894a4f82c4f2e27992ee8598727441', 9222483647, 0),
 ('Егор', 'Гречкин', '1979.10.02', 'casper.stefanie@example.org', 'c7dfeb1749280bf4483bbdec482424d0adb5fb42', 9137433647, 0),
 ('Егор', 'Сахаров', '1999.05.12', 'wmclaughlin@example.org', 'b6ac8e03dd77e8fd6474a99b65561ffc04cd81c8', 9137433637, 0),
 ('Саша', 'Иванов', '1983.02.12', 'tierra59@example.com', '34b23de558763dc4e3b4f0c710aa5319ae2a32ed', 9117181647, 1);


INSERT INTO delivery_zone (zone_name)
VALUES 
('ЦАО,САО,СВАО'),
('ВАО,ЮВАО, ЮАО'),
('ЮЗАО,ЗАО,СЗАО'),
('ЗЕАО,ТАО,НАО');





INSERT INTO adress (profiles_id, adress, delivery_zone_id)
VALUES 
('2', 'Давыдковская улица 3', '1'),
('4', 'Даниловский Вал, улица 8', '2'),
('6', 'Егерская улица 20', '1'),
('8', 'Елагинский проспект 1', '3'),
('1', 'Косинская улица 23', '2'),
('3', 'Есенинский бульвар 18', '1'),
('5', 'Кавказский бульвар 78', '1'),
('7', 'Радарная улица 2', '3'),
('9', 'Радарная улица 4', '3');


INSERT INTO warehouse (location, delivery_zone_id)
VALUES 
('Пушкина улица 3', '1'),
('Гоголя Вал, улица 8', '2'),
('Ленина улица 20', '3'),
('Елагинский проспект 1', '4');

INSERT INTO loyalty_card (profiles_id, balance)
VALUES 
('1', 0),
('2', 100),
('3', 2345),
('4', 765),
('5', 43),
('6', 0),
('7', 0),
('8', 8764),
('9', 34585)
;

INSERT INTO products (name, price, category, image, description)
VALUES 
('молоко', 35, 'напитки', NULL, 'молоко'),
('вода', 23, 'напитки', NULL, 'вода без газа'),
('колбаса', 283, 'мясо', NULL, 'колбаса вареная'),
('сыр', 164, 'молочка', NULL, 'сыр российский'),
('чай', 86, 'напитки', NULL, 'черный чай в пакетиках'),
('кофе', 275, 'напитки', NULL, 'кофе зерновой'),
('сок', 78, 'напитки', NULL, 'сок яблочный'),
('чипсы', 18, 'закуски', NULL, 'картофельные чипсы сыр'),
('кетчуп', 55, 'соусы', NULL, 'томатный кетчуп'),
('макароны', 79, 'крупы', NULL, 'макароны из твердых сортов пшеницы ')
;

INSERT INTO discount (discount_name, discount_size, products_id)
VALUES 
('скидка на молоко', 10, 1);




INSERT INTO orders_s (profiles_id, order_price, order_status, id_warehouse, loyalty_card_id)
VALUES 
(1, 1500, 'доставлено', 1, 1),
(2, 392, 'доставлено', 4, 2),
(3, 7833, 'доставлено', 2, 3),
(4, 4257, 'доставлено', 2, 4),
(5, 453, 'доставлено', 3, 5),
(6, 6543, 'доставлено', 4, 6),
(7, 7654, 'доставлено', 3, 7),
(8, 854, 'доставлено', 4, 8),
(9, 3547, 'доставлено', 4, 9)
;



INSERT INTO orders_details(orders_s_id, products_id, quantity, discount_id)
VALUES 
(1, 1, 2, NULL),
(1, 2, 2, NULl),
(2, 3, 4, NULl),
(2, 2, 1, NULl),
(4, 6, 3, NULl),
(4, 2, 6, NULl),
(5, 2, 3, NULl),
(5, 6, 4, NULl),
(5, 3, 5, NULl)
; 


INSERT INTO basket(profiles_id, products_id)
VALUES 
(1, 2),
(1, 3),
(1, 5),
(2, 3),
(2, 2),
(2, 4),
(3, 1),
(3, 2),
(4, 6),
(4, 5);

INSERT INTO payment (orders_s_id, status, summ, payment_type)
VALUES 
(1, 'оплачено', 340, 1),
(2, 'оплачено', 536, 3),
(3, 'оплачено', 3464, 1),
(4, 'не оплачено', 4792, 1),
(5, 'оплачено', 573, 1),
(6, 'не оплачено', 3573, 1),
(7, 'оплачено', 8654, 1),
(8, 'оплачено', 547, 1),
(9, 'не оплачено', 37490, 1)
;


INSERT INTO transactions_accrual(orders_s_id, points_sum)
VALUES 
(1, 34),
(2, 53),
(3, 346),
(4, 479),
(5, 573),
(6, 3573),
(7, 8564),
(8, 547),
(9, 3749)
;



