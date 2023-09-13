/* You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. 
There's not much data yet, but you can still try out some interesting queries. Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDat */

/* Q1 Find the names of all reviewers who rated Gone with the Wind  */

select distinct name 
/* reviewers' names are in reviewer table and the movies they rated are in rating table. 
Therefore, we join those two tables. We also pulled the movie ID using the given title. */
from reviewer V, rating R
where V.rID = R.rID 
	and mID in (select mID from movie where title = 'Gone with the Wind');
    
/* Q2 For any rating where the reviewer is the same as the director of the movie, 
return the reviewer name, movie title, and number of stars.  */

select name, title, stars
/* joining the three table with required columns */
from movie M, reviewer V, rating R 
	where M.mID = R.mID 
	and R.rID = V.rID 
    /*  name is reviewer's name while director is director's name*/
	and director = name;

/* Q3 Return all reviewer names and movie names together in a single list, alphabetized.
(Sorting by the first name of the reviewer and first word in the title is fine; 
no need for special processing on last names or removing "The".)  */

select name
from reviewer 
	union -- here we are using the union function to merge all those names into a single column
select  title
from movie    
order by name;

/* Q4 Find the titles of all movies not reviewed by Chris Jackson. */

select distinct title 
from movie 
/*subquery returns all the movies reviewed by Chris Jackson. NOT IN command used to exclude those.*/
where title not in (select title 
					from Movie M, reviewer V, rating R
					where M.mID = R.mID and V.rID = R.rID 
						and name = 'Chris Jackson');
                        
/* Q5 For all pairs of reviewers such that both reviewers gave a rating to the same movie, 
return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, 
and include each pair only once. For each pair, return the names in the pair in alphabetical order. */

select  distinct V1.name,  V2.name 
from reviewer V1, rating R1, reviewer V2, rating R2
where V1.rID = R1.rID 
	and R1.mID =R2.mID 
    /* following line eliminates duplicates*/
	and V1.name < V2.name
	and R2.rID = V2.rID
order by V1.name ;
				
/* Q6 For each rating that is the lowest (fewest stars) currently in the database, 
return the reviewer name, movie title, and number of stars. */

select V.name, M.title, R2.stars
/*subquery returns movies with the lowest stars*/
/*then join that return with other three tables and match reviewer, movie ID for only the movies with minimum stars*/
from (select rID, mID, R.stars, min(stars) as ms from  rating R) A, reviewer V, movie M, rating R2
		where R2.rID = V.rID and M.mID = R2.mID and R2.stars = ms ;

/* Q7 List movie titles and average ratings, from highest-rated to lowest-rated.
If two or more movies have the same average rating, list them in alphabetical order. */

/*using average aggregate function to find average ratings*/
select title, avg(stars) as avg_rating
from movie M, rating R
where M.mID = R.mID
/*grouping the results by titles*/
group by title 
/*descending order must be explicit*/
order by avg_rating desc, title;

/* Q8 Find the names of all reviewers who have contributed three or more ratings. 
(As an extra challenge, try writing the query without HAVING or without COUNT.) */

select name 
/*subquery counts the rating numbers for each reviewer. 
Using alias helps with comparison operator outside the subquery*/
from (select V.rID, name, count (R.rID) as contribution
	from reviewer V, rating R 
	where V.rID = R.rID 
	group by name)
where contribution >= 3;

/* Q9 Some directors directed more than one movie. For all such directors, 
return the titles of all movies directed by them, along with the director name. 
Sort by director name, then movie title. 
(As an extra challenge, try writing the query both with and without COUNT.) */

select title, director
from movie M1
/*subquery returns the count of all movies witht he same director name. 
Compared that count with 1 and pulled out the requested directors*/
where 1 < (select count(*) from movie M2 where M2.director = M1.director)
order by director, title;

/*Q10 Find the movie(s) with the highest average rating. 
Return the movie title(s) and average rating.
(Hint: This query is more difficult to write in SQLite than other systems; 
you might think of it as finding the highest average rating and then 
choosing the movie(s) with that average rating.)*/

select title, max(avg_rating)
/*subquery will return the movie titles and their average ratings.
needed to join two tables on mID and group the results by title. ordering was just for fun here*/
from ( select title, avg(stars) as avg_rating
		from movie M, rating R
		where M.mID = R.mID
		group by title 
		order by avg_rating desc, title);
        
/*Q11 Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
(Hint: This query may be more difficult to write in SQLite than other systems; you might think of it 
as finding the lowest average rating and then choosing the movie(s) with that average rating.)*/

select title, avg_rating
/*first find the average ratings of the movies and use alias for the average rating*/
from ( select title, avg(stars) as avg_rating
		from movie M, rating R
		where M.mID = R.mID
		group by M.title )
/*now use that average rating and compare it to the minimum average rating. 
Using nested subquery first to find the average and then return the minimum of the average value.
This is due to the nature of aggregate functions.*/
where avg_rating = 
		(  select min(avg_rating) 
			from (select title, avg(stars) as avg_rating
				from movie M, rating R
				where M.mID = R.mID
				group by M.title));
                
/*Q12 For each director, return the director's name together with the title(s) of the movie(s) 
they directed that received the highest rating among all of their movies, and the value of that rating.
 Ignore movies whose director is NULL. */
 
select director, title,stars
/*join movie and rating tables on mID*/
from Movie M join Rating R using (mID) 
/*ignoring the movies without directors using IS NOT NULL command*/
where director is not null
group by director -- grouping by director serves our purpose here. so that we get only one movie for each. 
having stars = max(stars) -- only interested in the highest rated movie. 
