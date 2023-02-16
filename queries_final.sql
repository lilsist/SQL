USE perekrestok;


-- узнаем, сколько товаров находится в каждой категории каждой категории

SELECT count(name) AS 'количество товаров в категории' , category AS категория
from products p 
group by category;


-- запрос показывает к какому адресу привязана зона доставки

SELECT adress, zone_name
FROM adress a
INNER JOIN delivery_zone dz  
ON a.delivery_zone_id  = dz.id ;



-- данное представления используется аналитиками c ограниченным правом доступа(только email и количество баллов,
-- без личных данных), кто не подпиал закон о персональных данных

CREATE OR REPLACE VIEW data_about_virtual_coins as (select email, balance 
FROM loyalty_card lc 
INNER JOIN profiles p 
ON lc.profiles_id = p.id
 ORDER BY balance DESC
);


-- представление о прибыли по дням для финансистов

CREATE OR REPLACE VIEW profit_per_day AS (
SELECT SUM(order_price) AS 'Сумма заказов за день', order_day AS День
FROM orders_s os 
GROUP BY order_day
);



-- данная транзакция служит для начисления баллов на карту лояльности за покупки

-- в рамках учебного проекта удалим часть начислений баллов из
-- таблицы и обработаем их начисление через транзакцию
DELETE FROM transactions_accrual WHERE orders_s_id IN (8, 9);

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS id_for_accruals;
CREATE TEMPORARY TABLE id_for_accruals (id BIGINT NOT NULL); -- создаем временную таблицу для хранения информации о баллах, 
-- которые не были еще зачислены

INSERT INTO id_for_accruals(id)
	SELECT id FROM orders_s 
	WHERE id NOT IN (
		SELECT orders_s_id
		FROM transactions_accrual)
;

SELECT * from id_for_accruals;


INSERT INTO transactions_accrual (orders_s_id, points_sum) -- зачисляем баллы(10% от суммы заказа) 
-- в таблицу об информации о начислении
SELECT id, order_price * 0.1
FROM orders_s 
WHERE id IN 
	( SELECT id 
	FROM id_for_accruals )
;

SELECT * FROM transactions_accrual;

select * from loyalty_card lc;

-- пополняем баланс карты лояльности покупателя

update loyalty_card set balance = balance + (
	select points_sum
	from transactions_accrual
	inner join orders_s
	on orders_s.id = transactions_accrual.orders_s_id
	where loyalty_card.profiles_id = orders_s.profiles_id)
	where profiles_id in (
		select profiles_id
		from orders_s os
		where id in (select id from id_for_accruals)
	)
;

select * from loyalty_card lc;

DROP TABLE id_for_accruals;

COMMIT;


-- данная процедура при вызове показывает прибыль за текущую дату

DROP PROCEDURE IF EXISTS profit_of_current_day;

DELIMITER //

CREATE PROCEDURE profit_of_current_day()
BEGIN

SELECT SUM(order_price) AS 'Сумма заказов за день', CURRENT_DATE() AS 'День'
FROM orders_s os 
WHERE DATE_FORMAT(order_day, '%Y-%m-%d') = CURRENT_DATE();

END //

DELIMITER ;


-- триггер работает в том случае, если в таблице loyalty_card будет вставлен NULL

DROP TRIGGER IF EXISTS correct_loyalty_card_details;

delimiter //
CREATE TRIGGER correct_loyalty_card_details BEFORE INSERT
ON loyalty_card
FOR EACH ROW
BEGIN
	IF new.balance is NULL then SET new.balance = 0;
	END IF;
END //
delimiter ;


