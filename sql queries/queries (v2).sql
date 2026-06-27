-- ============================================================
-- ANÁLISIS DE NEGOCIO — BASE DE DATOS SAKILA
-- Autor: Alberto Díaz González
-- ============================================================

-- Seleccionar todos los registros de alquiler (TABLA DESNORMALIZADA PARA ANÁLISIS)
SELECT						
p.payment_id AS ID_Pago,						
strftime('%Y-%m-%d', p.payment_date) AS Fecha_Completa,						
strftime('%Y-%m', p.payment_date) AS Año_Mes,						
p.amount AS Importe,						
r.rental_id AS ID_Alquiler,						
c.customer_id AS ID_Cliente,						
(c.first_name || ' ' || c.last_name) AS Nombre_Cliente,						
ci.city as Ciudad_Cliente,				
co.country as País_Cliente,					
s.store_id AS ID_Tienda,						
(staff.first_name || ' ' || staff.last_name) AS Nombre_Gerente,						
f.title AS Titulo_Pelicula,						
cat.name AS Categoria_Pelicula,						
round( julianday(r.return_date) - julianday(r.rental_date),2) AS Dias_Duracion_Alquiler						
FROM payment p						
JOIN rental r ON p.rental_id = r.rental_id						
JOIN customer c ON p.customer_id = c.customer_id						
JOIN staff staff ON p.staff_id = staff.staff_id						
JOIN store s ON staff.store_id = s.store_id						
JOIN inventory i ON r.inventory_id = i.inventory_id						
JOIN film f ON i.film_id = f.film_id						
JOIN film_category fc ON f.film_id = fc.film_id						
JOIN category cat ON fc.category_id = cat.category_id						
JOIN address ad ON c.address_id = ad.address_id						
JOIN city ci ON ad.city_id = ci.city_id						
JOIN country co ON ci.country_id = co.country_id						
ORDER BY ID_Pago	

-- Comprobación de todos los registros de alquileres que no se han devuelto (siguen activos)
	Seleccionar todos los resgitros de alquiler que no se han devuelto					
	SELECT					
	p.payment_id AS ID_Pago,					
	strftime('%Y-%m-%d', p.payment_date) AS Fecha_Completa,					
	strftime('%Y-%m', p.payment_date) AS Año_Mes,					
	p.amount AS Importe,					
	r.rental_id AS ID_Alquiler,					
	c.customer_id AS ID_Cliente,					
	(c.first_name || ' ' || c.last_name) AS Nombre_Cliente,					
	s.store_id AS ID_Tienda,					
	(staff.first_name || ' ' || staff.last_name) AS Nombre_Gerente,					
	f.title AS Titulo_Pelicula,					
	cat.name AS Categoria_Pelicula,					
	round( julianday(r.return_date) - julianday(r.rental_date),2) AS Dias_Duracion_Alquiler					
	FROM payment p					
	JOIN rental r ON p.rental_id = r.rental_id					
	JOIN customer c ON p.customer_id = c.customer_id					
	JOIN staff staff ON p.staff_id = staff.staff_id					
	JOIN store s ON staff.store_id = s.store_id					
	JOIN inventory i ON r.inventory_id = i.inventory_id					
	JOIN film f ON i.film_id = f.film_id					
	JOIN film_category fc ON f.film_id = fc.film_id					
	JOIN category cat ON fc.category_id = cat.category_id					
	WHERE Dias_Duracion_Alquiler is NULL					
	ORDER BY Fecha_Completa					

-- Pagos de alquiler de películas que no tienen asociado nigun rental_id					
SELECT payment_id, payment_date, amount, rental_id					
FROM payment					
WHERE rental_id IS NULL				
					