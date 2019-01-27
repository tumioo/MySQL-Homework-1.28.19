use sakila;

/** 1a. Display the first and last names of all actors from the table `actor`.*/
SELECT first_name, last_name
FROM actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. 
Name the column `Actor Name`.*/
SELECT CONCAT(first_name, ' ', last_name) As Actor_name FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/

SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';

/* 2c. Find all actors whose last names contain the letters `LI`. 
This time, order the rows by last name and first name, in that order:*/
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%LI%';

/* 2d. Using `IN`, display the `country_id` and `country` 
columns of the following countries: Afghanistan, Bangladesh, and China:*/

SELECT country_id, country FROM country WHERE country IN('Afghanistan','Bangladesh','China');

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries 
on a description, so create a column in the table `actor` named `description` and use the data type 
`BLOB` (Make sure to research the type `BLOB`, as the difference between it 
and `VARCHAR` are significant).*/
ALTER TABLE actor ADD COLUMN description blob;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
Delete the `description` column.*/

ALTER TABLE actor DROP COLUMN description;

/* 4a. List the last names of actors, as well as how many actors have that last name.*/
SELECT last_name,COUNT(*)
FROM actor      
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors.*/
SELECT last_name, COUNT(*) as lncnt
FROM actor
GROUP BY last_name
HAVING lncnt > 1;

/* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
`GROUCHO WILLIAMS`. Write a query to fix the record.*/
SELECT first_name, last_name FROM actor
WHERE last_name = 'WILLIAMS';

UPDATE actor SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! 
In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.*/
UPDATE actor SET first_name = "GROUCHO" 
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

/* 5a. You cannot locate the schema of the `address` table. 
Which query would you use to re-create it?*/

describe sakila.address;

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
Use the tables `staff` and `address`:*/

SELECT * FROM staff;
SELECT * FROM address;

SELECT first_name, last_name, address
FROM staff
JOIN address
USING (address_id);


/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
Use tables `staff` and `payment`.*/
SELECT * FROM staff;
SELECT * FROM payment;

SELECT staff.staff_id, staff.first_name, staff.last_name, sum(payment.Amount) 
FROM payment
INNER JOIN staff
ON staff.staff_id = payment.staff_id
WHERE payment_date
BETWEEN '2005-08-01' AND '2005-08-31'
group by staff_id;


/* 6c. List each film and the number of actors who are listed for that film. 
Use tables `film_actor` and `film`. Use inner join.*/
SELECT film.title, count(film_actor.actor_id) 
FROM film_actor
INNER JOIN film
ON film.film_id = film_actor.film_id
group by title;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/
SELECT * FROM inventory;
SELECT * FROM film;

SELECT film.title, count(film.film_id)
FROM inventory
INNER JOIN film
ON film.film_id = inventory.film_id
WHERE film.title = "HUNCHBACK IMPOSSIBLE";

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
list the total paid by each customer. List the customers alphabetically by last name:*/
SELECT * FROM payment;
SELECT * FROM customer;

SELECT customer.last_name, customer.first_name, sum(payment.amount) AS CustomerTotal
FROM customer
JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC ;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/
Select * from language limit 5;

SELECT title, language_id FROM film WHERE language_id = 1 and title like 'Q%' or title like 'K%';

/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/

SELECT * FROM actor;
SELECT * FROM film_actor;
SELECT * FROM film;

SELECT first_name, last_name FROM actor WHERE actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id IN
  (SELECT film_id FROM film WHERE title = "ALONE TRIP") );

/* 7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/

SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT c1.last_name, c1.first_name, c1.email, c2.country 
FROM customer c1
	INNER JOIN address a ON a.address_id = c1.address_id
    INNER JOIN city c3 ON c3.city_id = a.city_id 
	INNER JOIN country c2 ON c2.country_id = c3.country_id
    WHERE c2.country_id = 20
ORDER BY c1.last_name;

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as _family_ films.*/
SELECT * FROM film;
SELECT * FROM category;

SELECT title FROM film WHERE film_id IN 
(SELECT film_id FROM film_category WHERE category_id = 
	(SELECT category_id FROM category WHERE name = "Family"));

/* 7e. Display the most frequently rented movies in descending order.*/
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film;


SELECT f.title, COUNT(f.title) AS rent_count FROM rental AS r
	INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
	INNER JOIN film AS f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY rent_count DESC;


/* 7f. Write a query to display how much business, in dollars, each store brought in.*/

SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM payment;
SELECT * FROM city;
SELECT * FROM country;

SELECT a.address, cy.city, co.country, SUM(p.amount) AS total_revenue
FROM store AS s
	INNER JOIN address AS a ON s.address_id = a.address_id
	INNER JOIN customer AS c ON s.store_id=c.store_id
	INNER JOIN payment AS p ON p.customer_id = c.customer_id
	INNER JOIN city AS cy ON cy.city_id = a.city_id
	INNER JOIN country AS co ON co.country_id = cy.country_id
GROUP BY a.address, cy.city, co.country;
    
/* 7g. Write a query to display for each store its store ID, city, and country.*/

SELECT s.store_id, cy.city, co.country FROM store AS s
	INNER JOIN address AS a ON s.address_id = a.address_id
	INNER JOIN city AS cy ON cy.city_id = a.city_id
	INNER JOIN country AS co ON co.country_id = cy.country_id;


/* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/

SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;

SELECT c.name, SUM(p.amount) AS gross_revenue FROM category AS c
	INNER JOIN film_category AS fc ON c.category_id = fc.category_id
	INNER JOIN inventory AS i ON fc.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
	INNER JOIN payment AS p ON r.rental_id = p.rental_id
	GROUP BY name
    ORDER BY gross_revenue DESC
LIMIT 5;


/* 8a. In your new role as an executive, you would like to have an easy way of viewing the 
Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/

CREATE VIEW top5_genre_gross_revenue AS
SELECT c.name, SUM(p.amount) AS gross_revenue FROM category AS c
	INNER JOIN film_category AS fc ON c.category_id = fc.category_id
	INNER JOIN inventory AS i ON fc.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
	INNER JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5;


/* 8b. How would you display the view that you created in 8a?*/
SELECT * FROM top5_genre_gross_revenue;

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.*/
DROP VIEW IF EXISTS top5_genre_gross_revenue;


