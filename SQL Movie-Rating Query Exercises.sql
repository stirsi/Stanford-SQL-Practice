/* You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. 
There's not much data yet, but you can still try out some interesting queries. Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDat */

/* Q1 Find the titles of all movies directed by Steven Spielberg.*/

select title 
from Movie
where director = 'Steven Spielberg';

/* Q2 Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. */

select distinct year 
from movie M, Rating R
where M.mID = R.mID and stars >=4 
order by year;

/* Q3 Find the titles of all movies that have no ratings. */

select distinct title
from movie M, Rating R
/* looking for movie IDs which are not present in the Rating table */
where M.mID not in (select mID from Rating) ;

/* Q4 Some reviewers didn't provide a date with their rating. 
Find the names of all reviewers who have ratings with a NULL value for the date. */

select  name 
from Reviewer V, Rating R
/* joining reviewer and rating tables on rID and finding the date values which are null */
where V.rID = R.rID and ratingDate is NULL;

/* Q5 Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. 
Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. */

select name as reviewer_name, title as movie_title, stars, ratingDate 
/* joining three tables to gather all the columns requested. movie ID and reviewer ID are the keys. */
from movie M, reviewer V, rating R
where M.mID = R.mID and V.rID = R.rID
order by reviewer_name, movie_title, stars;

/* Q6 For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
return the reviewer's name and the title of the movie. */

select name, title
/* join three tables on keys*/
from movie M, rating R, reviewer V 
where M.mID = R.mID and V.rID = R.rID 
/* using exists operator to filter the reviewers requested behavior. Using R2 alias helps with matching information within the same table */
	and exists (select * from rating R2 where  R.rID = R2.rID and R.mID = R2.mID and R.stars >R2.stars and R.ratingDate > R2.ratingDate)
 
 /* Q7 For each movie that has at least one rating, find the highest number of stars that movie received. 
 Return the movie title and number of stars. Sort by movie title. */
 
/* using aggregate max function to find the highest number of stars */  
select title, max(stars)   
from movie M, Rating R -- joining two tables 
where M.mID = R.mID   -- key is mID
group by title  -- this groups the results by title and returns only the highest stars for each title
order by title
    
/* Q8 For each movie, return the title and the 'rating spread', that is, the difference between highest and 
lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. */

select title, mx-mn as rating_spread 
/* using the subquery to get the max and min stars for each movie and aliasing the max min values to use them in the arithmetic operation above*/ 
from (select title, max(stars) as mx, min(stars) as mn
	from movie M, rating R
	where M.mID = R.mID 
	group by title)
order by rating_spread desc, title;

/* Q9 Find the difference between the average rating of movies released before 1980 and 
the average rating of movies released after 1980. 
(Make sure to calculate the average rating for each movie, then the average of those averages 
for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) */

select avg(before_1980) - avg(after_1980)  
/* this subquery joins movie and rating tables and returns average stars for the movies released before 1980*/
from(select avg(stars) as before_1980
	from movie M, rating R where M.mID = R.mID and  year < 1980
	group by title) , -- comma separates the two subqueries since we are using the subqueries' results as tables in our query
/* this subquery joins movie and rating tables and returns average stars for the movies released after 1980*/
	(select avg(stars) as after_1980 
	from movie M, rating R
	where M.mID = R.mID and year > 1980
	group by title) 
;
