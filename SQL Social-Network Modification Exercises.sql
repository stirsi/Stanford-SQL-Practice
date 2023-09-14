/*Students at your hometown high school have decided to organize their social network using databases. 
So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema:

Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. 
Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2. 
Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. */

/*Q1 It's time for the seniors to graduate. Remove all 12th graders from Highschooler.*/

delete from Highschooler
where ID in (select ID 
			from Highschooler 
			where grade = 12)
            
/*Q2 If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. */

delete from likes
where ID1  in (	select distinct L.ID1
				from Highschooler H, Highschooler H2, Likes L, Likes L2, Friend F
				where (H.ID = F.ID1 and H2.ID = F.ID2) /*Student A is friends with Student B*/ 
				and (H.ID = L.ID1 and H2.ID = L.ID2) /*Student A likes Student B*/
                and (H.ID not in (select ID2 from Likes L2 where H2.ID = L2.ID1)) /*Student A is not liked when student B's ID in the ID1 column*/
			  )
              
/*Q3 For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. 
Do not add duplicate friendships, friendships that already exist, or friendships with oneself. 
(This one is a bit challenging; congratulations if you get it right.)*/

insert into Friend
select distinct ID1, ID3 
				/*join lists all the cases where A is friends with B, and B is friends with C*/
from Friend F1 inner join (select ID1 as ID2, ID2 as ID3 from Friend F2) using(ID2)
where ID1 <> ID3 /*this eliminates friendship with oneself*/
and ID1 not in (select F3.ID1 from Friend F3 where F3.ID2 = ID3) /*this line eliminates the already existing friendships*/
