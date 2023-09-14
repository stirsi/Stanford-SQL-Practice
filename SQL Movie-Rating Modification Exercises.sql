/*You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. 
There's not much data yet, but you can still try out some data modifications. Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.*/

/*Q1 Add the reviewer Roger Ebert to your database, with an rID of 209. */

insert into reviewer values ('209', 'Roger Ebert')

/*Q2 For all movies that have an average rating of 4 stars or higher,
 add 25 to the release year. (Update the existing tuples; don't insert new tuples.)*/
 
update movie
set year = year + 25
where title in ( select title 
				from   (select title,  avg(stars) as avg_rating  /*subquery returns average rating for all movies*/
						from movie M, rating R 
                        where M.mID = R.mID 
                        group by title)
				where avg_rating >= 4)   /*filtering movies with ratings of 4 or higher*/
                
/*Q3 Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.*/

delete  from rating
/*filtering movies made before 1970 or after 2000*/
where mID in (select R.mID 
			from rating R, movie M
			where M.mID = R.mID 
			and (year < 1970 or year > 2000))
	/*also filtering movies with less than 4 stars*/
    and stars < 4;