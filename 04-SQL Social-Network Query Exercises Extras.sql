-- Q1
-- For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade, HS3.name, HS3.grade
FROM (
    SELECT L1.ID1 ID1, L1.ID2 ID2, L2.ID2 ID3
    FROM Likes L1
        JOIN Likes L2 ON L1.ID2 = L2.ID1
    WHERE L1.ID1 <> L2.ID2
    ) StudentIDs
    JOIN Highschooler HS1 ON HS1.ID = StudentIDs.ID1
    JOIN Highschooler HS2 ON HS2.ID = StudentIDs.ID2
    JOIN Highschooler HS3 ON HS3.ID = StudentIDs.ID3;

-- Q2
-- Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.

SELECT Highschooler.name, Highschooler.grade
FROM Highschooler
WHERE NOT Exists (
    SELECT *
    FROM Friend
        JOIN Highschooler HS2 ON Friend.ID2 = HS2.ID
    WHERE Friend.ID1 = Highschooler.ID
        AND HS2.grade = Highschooler.grade
)
ORDER BY Highschooler.grade, Highschooler.name;

--Someone with no friends ?

-- Q3
-- What is the average number of friends per student? (Your result should be just one number.)

SELECT AVG(FCount)
FROM (
    Select COUNT(Friend.ID2) FCount
    FROM Friend
    GROUP BY Friend.ID1
) FriendsCount;

-- Q4
-- Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.

SELECT COUNT(DISTINCT Friend.ID1)
FROM Friend
WHERE Friend.ID2 in (SELECT ID from Highschooler WHERE name = 'Cassandra')
    OR (Friend.ID2 in (SELECT ID2 from Friend WHERE ID1 in (SELECT ID from Highschooler WHERE name = 'Cassandra'))
        AND Friend.ID1 not in (SELECT ID from Highschooler WHERE name = 'Cassandra'));

-- Q5
-- Find the name and grade of the student(s) with the greatest number of friends.

Select HS.name, HS.grade
FROM Highschooler HS
    JOIN (
        SELECT ID1, Count(ID2) fcount
        FROM Friend
        GROUP BY ID1
    ) FriendsCount ON FriendsCount.ID1 = HS.ID
WHERE fcount = (SELECT MAX(fcount) FROM (
        SELECT ID1, Count(ID2) fcount
        FROM Friend
        GROUP BY ID1
    ) FriendsCount);

-- WITH AS

WITH FriendsCount AS (
        SELECT ID1, Count(ID2) fcount
        FROM Friend
        GROUP BY ID1
    )
Select HS.name, HS.grade
FROM Highschooler HS
    JOIN FriendsCount ON FriendsCount.ID1 = HS.ID
WHERE fcount = (SELECT MAX(fcount) FROM FriendsCount);
