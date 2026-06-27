-- ============================================================
-- ANÁLISIS DE NEGOCIO — BASE DE DATOS SAKILA
-- Autor: Alberto Díaz González
-- ============================================================

-- 1. ¿Cuánto recaudamos por mes?
SELECT
    strftime('%Y-%m', payment_date) AS Año_Mes,
    SUM(amount) AS Facturación
FROM payment
GROUP BY Año_Mes
ORDER BY Año_Mes ASC;


-- 2. ¿Cuáles son las 5 categorías de películas que más ingresos generan?
SELECT
    c.category_id AS Id,
    c.name AS Categoria,
    SUM(amount) AS Facturacion
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY c.category_id, c.name
ORDER BY Facturacion DESC
LIMIT 5;


-- 3. ¿Qué 10 películas tuvieron más alquileres?
SELECT
    f.film_id AS ID,
    f.title AS Película,
    COUNT(r.rental_id) AS Cantidad_de_Alquileres
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY Película
ORDER BY Cantidad_de_Alquileres DESC
LIMIT 10;


-- 4. ¿Quiénes son nuestros 10 mejores clientes (Top VIP)?
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS Nombre_cliente,
    SUM(p.amount) AS Facturación
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY Nombre_cliente
ORDER BY Facturación DESC
LIMIT 10;


-- 5. Top 3 películas por facturación en categorías Acción y Comedia
WITH RANKED_CATEGORIES AS (
    SELECT
        c.name AS Categoría,
        f.title AS Película,
        SUM(p.amount) AS Facturación,
        ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY SUM(p.amount) DESC) AS RANKING
    FROM category c
    JOIN film_category fc ON fc.category_id = c.category_id
    JOIN film f ON f.film_id = fc.film_id
    JOIN inventory i ON i.film_id = fc.film_id
    JOIN rental r ON r.inventory_id = i.inventory_id
    JOIN payment p ON p.rental_id = r.rental_id
    GROUP BY Categoría, Película
)
SELECT Categoría, Película, Facturación, RANKING
FROM RANKED_CATEGORIES
WHERE RANKING <= 3
AND Categoría IN ('Action', 'Comedy');


-- 6. Análisis de fidelidad — clientes que alquilaron en más de un mes
SELECT COUNT(customer_id) AS Clientes_Fieles
FROM (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING COUNT(DISTINCT strftime('%m', payment_date)) > 1
);


-- 7. Rendimiento por tienda y gerente
SELECT
    s.store_id AS Tienda,
    CONCAT(staff.first_name, ' ', staff.last_name) AS Gerente,
    COUNT(DISTINCT r.rental_id) AS Total_Alquileres,
    SUM(p.amount) AS Facturacion_Total,
    ROUND(SUM(p.amount) / COUNT(DISTINCT r.rental_id), 2) AS Ticket_promedio
FROM store s
JOIN staff ON s.manager_staff_id = staff.staff_id
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY s.store_id;


-- 8. Duración promedio de alquiler por categoría
SELECT
    c.name AS Categoria,
    ROUND(AVG(julianday(r.return_date) - julianday(r.rental_date)), 1) AS Dias_Promedio_Alquiler
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN film f ON f.film_id = fc.film_id
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY c.name
ORDER BY Dias_Promedio_Alquiler DESC;
