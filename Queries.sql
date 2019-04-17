USE sakila;
SELECT * FROM actor;

#1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `Actor Name` FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

#2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant)
ALTER TABLE actor
ADD COLUMN description BLOB(255) AFTER last_update;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(actor_id) AS actors_number
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(actor_id) AS actors_number
FROM actor
GROUP BY last_name
HAVING COUNT(actor_id) >= 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT first_name, last_name
FROM actor
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
UPDATE actor 
SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SELECT first_name, last_name
FROM actor
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";
UPDATE actor 
SET first_name = "GROUCHO" 
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff LEFT JOIN address ON (staff.address_id = address.address_id);

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS total_amount
FROM payment LEFT JOIN staff ON (staff.staff_id = payment.staff_id)
WHERE payment.payment_date LIKE "%2005-08-%"
GROUP BY staff.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS actors_number
FROM film INNER JOIN film_actor ON (film.film_id = film_actor.film_id)
GROUP BY film.film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory;
SELECT film.title, COUNT(inventory.inventory_id) AS copies_number
FROM inventory LEFT JOIN film ON (film.film_id = inventory.film_id)
WHERE film.title = UPPER("Hunchback Impossible")
GROUP BY film.film_id;

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS total_paid
FROM customer LEFT JOIN payment ON (customer.customer_id = payment.customer_id)
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM language;
SELECT film.title
FROM film
WHERE language_id IN
	(SELECT language.language_id
	FROM language
	WHERE language.name = "English")
	AND 
    (film.title LIKE "K%" OR film.title LIKE "Q%");
    
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor_id IN
	(SELECT film_actor.actor_id
	FROM film_actor
	WHERE film_id IN
		(SELECT film.film_id
		FROM film
		WHERE film.title = UPPER("Alone Trip"))); 
        
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM 
customer
INNER JOIN 
(SELECT address.address_id AS tmp_address_id, address.city_id
	FROM address 
	INNER JOIN   
		(SELECT city.city_id AS tmp_city_id 
			FROM 
			city
			INNER JOIN
			(SELECT country.country_id AS tmp_country_id
				FROM country
				WHERE country = "Canada"
				) AS tmp_city_tab
			ON (city.country_id = tmp_city_tab.tmp_country_id)
			) AS tmp_city_tab
	ON (address.city_id = tmp_city_tab.tmp_city_id)  
	) AS tmp_address_tab
ON (customer.address_id = tmp_address_tab.tmp_address_id);

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film.title
	FROM film
	INNER JOIN
	(SELECT film_category.film_id AS tmp_film_id
		FROM film_category
		INNER JOIN
		(SELECT category.category_id AS tmp_cat_id
			FROM category
			WHERE category.name = "Family"
			) AS tmp_cat_tab
		ON (film_category.film_id = tmp_cat_tab.tmp_cat_id)
		) AS tmp_film_tab
	ON (film.film_id = tmp_film_tab.tmp_film_id);
    
#7e. Display the most frequently rented movies in descending order.
SELECT film.title, film.rental_rate 
FROM film
ORDER BY film.rental_rate DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT SUM(payment.amount) AS total, customer.store_id
FROM payment LEFT JOIN customer
ON (payment.customer_id = customer.customer_id)
GROUP BY customer.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, address.city_id, city.city, city.country_id, country.country
FROM store 
LEFT JOIN address
ON (store.address_id = address.address_id)
LEFT JOIN city
ON (address.city_id = city.city_id)
LEFT JOIN country
ON (country.country_id = city.country_id);

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM payment
LEFT JOIN rental
ON (payment.rental_id = rental.rental_id)
LEFT JOIN inventory
ON (rental.inventory_id = inventory.inventory_id)
LEFT JOIN film_category
ON (inventory.film_id = film_category.film_id)
LEFT JOIN category
ON (film_category.category_id = category.category_id)
GROUP BY category.name
ORDER BY gross_revenue DESC
LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS SELECT category.name, SUM(payment.amount) AS gross_revenue
								FROM payment
								LEFT JOIN rental
								ON (payment.rental_id = rental.rental_id)
								LEFT JOIN inventory
								ON (rental.inventory_id = inventory.inventory_id)
								LEFT JOIN film_category
								ON (inventory.film_id = film_category.film_id)
								LEFT JOIN category
								ON (film_category.category_id = category.category_id)
								GROUP BY category.name
								ORDER BY gross_revenue DESC
								LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;



