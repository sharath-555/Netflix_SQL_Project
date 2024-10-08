--Business Problem to be solved for the Netflix Dataset!!!

--Count No of Movies and TV Shows in Database
select type,count(*) as count_of_content
from netflix
group by type

-- 2. Find the most common rating for movies and TV shows
with ratingCounts as (SELECT type,rating,COUNT(*) AS rating_count
FROM netflix
GROUP BY type, rating),
RankedRatings as (
select type,rating,rating_count,
		rank() over(partition by type order by rating_count desc) as rnk
from ratingCounts
)
select *
from RankedRatings
where rnk =1 

-- 3. List all movies released in a specific year (e.g., 2020)
select * 
from netflix
where type = 'Movie' and release_year = 2020

--4. Find the top 5 countries with the most content on Netflix
select unnest(string_to_array(country,',')) as new_country,
		count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

--5. Identify the longest movie
select type, title,country, duration
from netflix
where type = 'Movie' and duration is not null
order by split_part(duration, ' ', 1)::int desc
limit 1

--6. Find content added in the last 5 years
select *
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'

--7. Find all the movies/TV shows by direcor 'Ridley Scott'!
select *
from (select *,
			unnest(string_to_array(director, ',')) as director_name
	from 
	netflix)
where director_name = 'Ridley Scott'

-- 8. List all TV shows with more than 5 seasons
select *
from netflix
where type = 'TV Show' and split_part(duration, ' ', 1)::int > 5

-- 9. Count the number of content items in each genre

select unnest(string_to_array(listed_in, ',')) as genre,
	count(*) as total_content
from netflix
group by 1

--10. Find each year and the average numbers of content release by United States on netflix. 
-- return top 5 year with highest avg content release !
select extract(year from to_date(date_added,'Month DD,YYYY')) as year, count(*),
		round(count(show_id)::numeric/(select count(show_id) from netflix where country = 'India')::numeric * 100 ,2) as avg_release
from netflix
where country = 'United States' and extract(year from to_date(date_added,'Month DD,YYYY')) is not null
group by 1
order by avg_release desc
limit 5

--11. List all movies that are documentaries
select *
from netflix
where listed_in like '%Documentaries%'

--12.Find all content without a director
select *
from netflix
where director is null

--13. Find how many movies actor 'Harrison Ford' appeared in last 50 years!
select *
from netflix
where casts like '%Harrison Ford%' and release_year > extract(year from current_date)-50

--14. Find the top 10 actors who have appeared in the highest number of movies produced in United States
select unnest(string_to_array(casts,',')) as actors, count(*) as total_content
from netflix
where country ilike '%United States%'
group by 1
order by 2 desc
limit 10


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
select category,type, count(*) as content_count
from (select *, case when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
            	else 'Good' end as category
      from netflix) as categorized_content
group by 1,2
order by 2