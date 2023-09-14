/* Students at your hometown high school have decided to organize their social network using databases. 
So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema:

Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. 
Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2. 
Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. */

/* Q1 For every situation where student A likes student B, but student B likes a different student C, 
return the names and grades of A, B, and C.*/

select distinct H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Highschooler H1,Highschooler H2, Likes L1, Likes L2, Highschooler H3
where (H1.ID = L1.ID1 and H2.ID = L1.ID2)  /*student A likes student B*/
	and (H2.ID = L2.ID1 and H3.ID = L2.ID2) /*student B likes student C*/
    and H3.ID <> H1.ID   /*Student C is different from Student A*/
    
/*Q2 Find those students for whom all of their friends are in different grades from themselves.
    Return the students' names and grades.*/
    
select name, grade
from       /*subquery returns all friends name, grade and ID1*/
		(select distinct H1.name, H1.grade, F1.ID1
		from  Friend F1, Friend F2, Highschooler H1,Highschooler H2 
		where H1.ID = F1.ID1 
			and  F1.ID2 = H2.ID )
	
where ID1 not in   /*subquery returns ID1s for all friend pairs in the same grade. */
		(select F1.ID1
		from  Friend F1, Friend F2, Highschooler H1,Highschooler H2 
		where H1.ID = F1.ID1 
		and  F1.ID2 = H2.ID 
		and H1.grade = H2.grade)
order by grade, name

/*Q3 What is the average number of friends per student? (Your result should be just one number.)*/

select avg(friend_count)
from   /*subquery will bring the friend count for every student*/
	(select H.name, count (ID1) as friend_count
	from Highschooler H, Highschooler H2,  Friend F
	where H.ID = F.ID1 
	and H2.ID = F.ID2
	group by H.ID
order by H.grade)

/*Q4 Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra.
Do not count Cassandra, even though technically she is a friend of a friend.*/

select count(ID2)   /*counts number of students who are friends with Cassandra*/
	from   /* first subquery returns students' IDs friended by someone named Cassandra*/
		( select F.ID2
		from  Friend F
		where ID1 = (select ID from Highschooler where name = 'Cassandra')
		union  /*merging two result tables */
		select ID2 from Friend  /*students who friended Cassandra's friends except Cassandra herself*/
		where ID1 in  /*finding students who friended Cassandra's friends */ 
				(select F.ID2
				from  Friend F
				where ID1 = (select ID from Highschooler where name = 'Cassandra')) 
			and ID2 <> (select ID from Highschooler where name = 'Cassandra')  /*eliminating Cassandra from friend of a friend count*/
        )
        
/* Q5 Find the name and grade of the student(s) with the greatest number of friends.*/

select name, grade 
from  /*selecting from students and their friend count. need friend count as alias to apply aggregate max function next*/
	(select H.name, H.grade, count (ID1) as friend_count
	from Highschooler H, Highschooler H2,  Friend F
	where H.ID = F.ID1 
	and H2.ID = F.ID2
	group by H.ID
	order by friend_count desc
	)
    /*filtering the students with the most friend count using max*/
where friend_count = (select max(friend_count) as max_friend
					from  /*using the same subquery counting friends*/
						(select H.name, H.grade, count (ID1) as friend_count
						from Highschooler H, Highschooler H2,  Friend F
						where H.ID = F.ID1 
						and H2.ID = F.ID2
						group by H.ID
						order by friend_count desc)
						)
