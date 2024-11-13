-- 1. Вывести всех покупателей из указанного списка стран: отобразить имя, фамилию, страну.
SELECT customer.first_name, customer.last_name, country.country
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country IN ('United States', 'Canada', 'Australia');

-- 2. Вывести все фильмы, в которых снимался указанный актер: отобразить название фильма, жанр.
SELECT film.title, category.name AS genre
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE actor.first_name = 'NICK' AND actor.last_name = 'WAHLBERG';

-- 3. Вывести топ 10 жанров фильмов по величине дохода в указанном месяце: отобразить жанр, доход.
SELECT category.name AS genre, SUM(payment.amount) AS revenue
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE MONTH(payment.payment_date) = 7
GROUP BY genre
ORDER BY revenue DESC
LIMIT 10;

-- 4. Вывести список из 5 клиентов, упорядоченный по количеству купленных фильмов с указанным актером, начиная с 10-й позиции: отобразить имя, фамилию, количество купленных фильмов.
SELECT customer.first_name, customer.last_name, COUNT(payment.payment_id) AS film_count
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_actor ON inventory.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'NICK' AND actor.last_name = 'WAHLBERG'
GROUP BY customer.customer_id
ORDER BY film_count DESC
LIMIT 5 OFFSET 10;

-- 5. Вывести для каждого магазина его город, страну расположения и суммарный доход за первую неделю продаж.
SELECT store.store_id, city.city, country.country, SUM(payment.amount) AS total_revenue
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
JOIN staff ON store.store_id = staff.store_id
JOIN payment ON staff.staff_id = payment.staff_id
WHERE WEEK(payment.payment_date) = 1
GROUP BY store.store_id;

-- 6. Вывести всех актеров для фильма, принесшего наибольший доход: отобразить фильм, имя актера, фамилия актера.
SELECT film.title, actor.first_name, actor.last_name
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.film_id = (
   SELECT inventory.film_id
   FROM payment
   JOIN rental ON payment.rental_id = rental.rental_id
   JOIN inventory ON rental.inventory_id = inventory.inventory_id
   GROUP BY inventory.film_id
   ORDER BY SUM(payment.amount) DESC
   LIMIT 1
);

-- 7. Для всех покупателей вывести информацию о покупателях и актерах-однофамильцах (используя LEFT JOIN, если однофамильцев нет – вывести NULL).
SELECT customer.first_name AS customer_first_name, customer.last_name AS customer_last_name,
       actor.first_name AS actor_first_name, actor.last_name AS actor_last_name
FROM customer
LEFT JOIN actor ON customer.last_name = actor.last_name;

-- 8. Для всех актеров вывести информацию о покупателях и актерах-однофамильцах (используя RIGHT JOIN, если однофамильцев нет – вывести NULL).
SELECT actor.first_name AS actor_first_name, actor.last_name AS actor_last_name,
       customer.first_name AS customer_first_name, customer.last_name AS customer_last_name
FROM actor
RIGHT JOIN customer ON actor.last_name = customer.last_name;

-- 9. В одном запросе вывести статистические данные о фильмах:
-- 9.1. Длина самого продолжительного фильма – отобразить значение длины; количество фильмов, имеющих такую продолжительность.
SELECT MAX(length) AS longest_length, COUNT(*) AS count_longest
FROM film
WHERE length = (SELECT MAX(length) FROM film);

-- 9.2. Длина самого короткого фильма – отобразить значение длины; количество фильмов, имеющих такую продолжительность.
SELECT MIN(length) AS shortest_length, COUNT(*) AS count_shortest
FROM film
WHERE length = (SELECT MIN(length) FROM film);

-- 9.3. Максимальное количество актеров в фильме – отобразить максимальное количество актеров; количество фильмов, имеющих такое число актеров.
SELECT max_actor_count, COUNT(*) AS count_max_actor
FROM (
   SELECT film.film_id, COUNT(film_actor.actor_id) AS actor_count
   FROM film
   JOIN film_actor ON film.film_id = film_actor.film_id
   GROUP BY film.film_id
) AS actor_counts
WHERE actor_count = (SELECT MAX(actor_count) FROM actor_counts);

-- 9.4. Минимальное количество актеров в фильме - отобразить минимальное количество актеров; количество фильмов, имеющих такое число актеров.
SELECT min_actor_count, COUNT(*) AS count_min_actor
FROM (
   SELECT film.film_id, COUNT(film_actor.actor_id) AS actor_count
   FROM film
   JOIN film_actor ON film.film_id = film_actor.film_id
   GROUP BY film.film_id
) AS actor_counts
WHERE actor_count = (SELECT MIN(actor_count) FROM actor_counts);
