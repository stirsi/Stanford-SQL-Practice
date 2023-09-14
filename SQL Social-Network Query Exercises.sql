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

/* Q1 Find the names of all students who are friends with someone named Gabriel.*/

select distinct name 
from Friend F JOIN Highschooler H ON  H.ID = F.ID1  
/*after joining tables H and F using ID1, looking for ID2 matching name Gabriel (there is more than one Gabriel*/
	and ID2 in (select distinct ID from Highschooler where name = 'Gabriel')
    
/*Q2 For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade,
and the name and grade of the student they like.*/

select distinct H1.name, H1.grade, H2.name, H2.grade  
from Highschooler H1,Highschooler H2, Likes L1, Likes L2  /* joining tables*/
where H1.ID = L1.ID1  /* student A matching ID1 on the Likes table*/
	and H1.grade - 2 >= H2.grade   /*student A's grade is 2 or more grades bigger than the other (liked) student*/
    and L1.ID2 = H2.ID            /*other liked student matching ID2 on the Likes table*/
    
/*Q3 For every pair of students who both like each other, return the name and grade of both students.
Include each pair only once, with the two names in alphabetical order. */

select  H1.name, H1.grade, H2.name, H2.grade  
from Highschooler H1,Highschooler H2, Likes L1, Likes L2 
where H1.ID = L1.ID1  /*Student A likes*/
	and L1.ID2 = H2.ID /*Student B is liked*/
	and L1.ID1 = L2.ID2 /*Student A likes Student B*/
	and L1.ID2 = L2.ID1  /* Student B likes Student A */
	and H1.name < H2.name   /*Eliminating duplicate pairs*/
	order by H1.name, H2.name
    
/*Q4 Find all students who do not appear in the Likes table (as a student who likes or is liked) and
 return their names and grades. Sort by grade, then by name within each grade. */
 
select distinct name, grade 
from Highschooler H, Likes L 
where ID not in (select ID1 from Likes) 
	and ID not in (select ID2 from Likes)
	order by grade, name
    
/*Q5 For every situation where student A likes student B, but we have no information about whom B likes
(that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. */
 
select  distinct H1.name, H1.grade, H2.name, H2.grade  
from Highschooler H1,Highschooler H2, Likes L1, Likes L2 
where L1.ID1 = H1.ID    /*Student A likes*/
	and L1.ID2 = H2.ID  /*Student B is liked*/
	and L1.ID2 not in (select L2.ID1 from Likes L2)  /*Student B's ID is not in the Likes table as ID1*/
    
/*Q6 Find names and grades of students who only have friends in the same grade. 
Return the result sorted by grade, then by name within each grade. */
 
select name, grade
from (                  /*subquery of names of students and their friends*/
	select distinct H1.name, H1.grade, F1.ID1
	from  Friend F1, Friend F2, Highschooler H1,Highschooler H2 
	where H1.ID = F1.ID1 
	and  F1.ID2 = H2.ID )
	
where ID1 not in     /*subquery returns ID1s for students who are friends and in different grades*/
	(select F1.ID1
	from  Friend F1, Friend F2, Highschooler H1,Highschooler H2 
	where H1.ID = F1.ID1 
	and  F1.ID2 = H2.ID 
	and H1.grade <>H2.grade)
order by grade, name

/*Q7 For each student A who likes a student B where the two are not friends, find if they have a friend C
in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.*/

select distinct H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Friend F1, Friend F2, Highschooler H1,Highschooler H2, Likes L1, Likes L2, Highschooler H3
where (H1.ID = L1.ID1 and H2.ID = L1.ID2)           /*Student A likes student B*/
	and H2.ID not in (select ID2 from Friend where ID1 = H1.ID)  /*Student B's ID is not in the ID2 column where student A's is in ID1 - they are not friends*/
	and (H1.ID = F1.ID1 AND H3.ID = F1.ID2)  /*Student A is friends with Student C*/
    and (H2.ID = F2.ID1 and H3.ID = F2.ID2); /*Student B is friends with Student C*/
    
/*Q8 Find the difference between the number of students in the school and the number of different first names.*/    

select 
	(select count (ID) from Highschooler) -                /*number of students*/
    (select count (distinct name) from Highschooler) as difference   /*number of different first names*/
    
/*Q9 Find the name and grade of all students who are liked by more than one other student.*/

select name, grade 
/*subquery will bring the students and their being liked count*/
from (select  H.name, H.grade, count(ID2) as popularity 
	from Likes L, Highschooler H 
	where H.ID = L.ID2 
	group by ID2)
where popularity >1
