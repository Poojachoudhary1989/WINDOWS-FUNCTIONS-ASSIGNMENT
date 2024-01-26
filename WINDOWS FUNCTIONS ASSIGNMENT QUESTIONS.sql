-- WINDOWS FUNCTIONS ASSIGNMENT QUESTIONS
use mavenmovies;
-- QUS1. Rank the customer based on the total amount they have spent on rentals. 

select first_name,c.customer_id, sum(amount), rank() over(order by sum(amount) desc)  from payment p  join  customer c on p.customer_id=c.customer_id
                                                          group by c.customer_id;

-- QUS2. Calculate the cumulative revenue generated by each film over time. 

select title,sum(amount)over(partition by title) from film join payment on film.film_id=payment.rental_id;


-- QUS3. Determine the average rental duration for each film ,cosidering films with similar length. 

select title ,rental_duration,avg(rental_duration) over(partition by title) from film;

-- QUS4. Identify the top three films in each category based on their rental counts.
                                                   
select category_id,film_id,title,Rental_count,Ranking from(select fc.category_id,fc.film_id,f.title,count(rental_id) as Rental_count,row_number() 
                                        over(partition by fc.category_id order by count(r.rental_id)desc ) as Ranking 
                                        from film_category fc join rental r on  fc.film_id=r.inventory_id
											                  join film f on fc.film_id=f.film_id group by fc.category_id,fc.film_id,f.title,category_id) Temp
															  where ranking <=3 order by category_id;
                        
-- QUS5. Calculate the difference in rental counts between each customers total rental and the average rentals across all customers.

select customer_id,count(rental_id)as Total_rental , avg(count(rental_id))over() as Average_rental,count(rental_id)-avg(count(rental_id)) over() as Diff_in_rental_counts 
from payment group by customer_id;

-- QUS6. Find the monthly revenue trend for the entire rental store over time. 

select monthname(payment_date),sum(amount) as Monthly_revenue,sum(amount)-lag(sum(amount))over(order by month(payment_date)asc) as Monthly_revenue_trend
 from payment group by monthname(payment_date),month(payment_date); -- Monthly revenue trend is positive or negative.


-- QUS7. Identify the customers whose total spending on rentals falls within the top 20% of all customers.
                                
select customer_id,first_name,Total_spend from (select c.customer_id,first_name,sum(amount) as Total_spend,percent_rank()over(order by sum(amount)desc ) 
                      as percent from payment p join customer c on p.customer_id=c.customer_id 
                       group by customer_id) temp where percent <=0.2 order by Total_spend desc;

-- QUS8. Calculate the running total of rentals per category ,ordered by rental count.
       
select category_id,Rental_count,sum(rental_count)over(order by Rental_count) as Running_total from (select fc.category_id,count(rental_id) as Rental_count from film_category fc join rental r on  fc.film_id=r.inventory_id
											                  join film f on fc.film_id=f.film_id  group by category_id) temp ;
                                                              
-- QUS9.Find the films that have been rented less than the average rental count for their respective category.

select title,category_id,Rental_count,Average_count,Rented_less from (select  title,fc.category_id,count(rental_id) as Rental_count,avg(count(rental_id))over(partition by category_id) as Average_count,
                                                         avg(count(rental_id))over(partition by category_id)-count(rental_id) as Rented_less
															  from film_category fc join rental r on  fc.film_id=r.inventory_id
						join film f on fc.film_id=f.film_id  group by title,category_id ) temp where Rented_less>0;

-- QUS10.Identify the top 5 months with the highest revenue and display the revenue generated each month.

select monthname(payment_date),sum(amount) as Revenue_total,rank()over(order by sum(amount)desc) as Ranking from payment group by monthname(payment_date) limit 5;







