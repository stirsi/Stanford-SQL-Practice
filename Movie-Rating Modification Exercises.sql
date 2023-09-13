/*SQL Movie-Rating Modification Exercises

You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. 

Movie ( mID, title, year, director )

Reviewer ( rID, name )

Rating ( rID, mID, stars, ratingDate )*/

/*Task 1: Add the reviewer Roger Ebert to your database, with an rID of 209.*/

Insert into Reviewer values (209, 'Roger Ebert');

/*Task 2: For all movies that have an average rating of 4 stars or higher, add 25 to the release year.*/

update Movie
set year = year + 25
where Movie.mID in (select mid from Rating group by mID
having avg(stars) >=4);

/*Task 3: Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.*/

delete from Rating
where mID in (select mid from movie where year<1970 or year>2000) and stars < 4;
