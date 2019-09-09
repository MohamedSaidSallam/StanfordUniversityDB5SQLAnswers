-- Q1
-- Find the names of all students who are friends with someone named Gabriel.

SELECT HS2.name
FROM Highschooler HS1
    JOIN Friend ON Friend.ID1 = HS1.ID
    JOIN Highschooler HS2 ON Friend.ID2 = HS2.ID
WHERE HS1.name = 'Gabriel';

-- Q2
-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade
FROM Highschooler HS1
    JOIN Likes ON Likes.ID1 = HS1.ID
    JOIN Highschooler HS2 ON Likes.ID2 = HS2.ID
WHERE HS1.grade - HS2.grade >= 2;

-- Q3
-- For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade
FROM Highschooler HS1
    JOIN Likes ON Likes.ID1 = HS1.ID
    JOIN Highschooler HS2 ON Likes.ID2 = HS2.ID
WHERE HS1.ID <> HS2.ID
    AND HS1.name < HS2.name
    AND EXISTS (SELECT *  FROM Likes WHERE Likes.ID1 = HS2.ID AND Likes.ID2 = HS1.ID);

-- Q4
-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.

SELECT Highschooler.name, Highschooler.grade
FROM Highschooler
WHERE Highschooler.ID not in (
    SELECT ID1 ID
    From Likes
    UNION
    SELECT ID2 ID
    From Likes
)
ORDER BY Highschooler.grade, Highschooler.name;

-- Q5
-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.

SELECT HS1.name, HS1.grade, HS2.name, HS2.grade
FROM Highschooler HS1
    JOIN Likes ON Likes.ID1 = HS1.ID
    JOIN Highschooler HS2 ON Likes.ID2 = HS2.ID
WHERE HS2.ID not in (SELECT ID1 FROM Likes);

-- Q6
-- Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.

SELECT Highschooler.name, Highschooler.grade
FROM Highschooler
WHERE NOT Exists (
    SELECT *
    FROM Friend
        JOIN Highschooler HS2 ON Friend.ID2 = HS2.ID
    WHERE Friend.ID1 = Highschooler.ID
        AND HS2.grade <> Highschooler.grade
)
ORDER BY Highschooler.grade, Highschooler.name;

-- Q7
-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.

SELECT LikesNotFriends.name1, LikesNotFriends.grade1, LikesNotFriends.name2, LikesNotFriends.grade2, HS3.name, HS3.grade
FROM
    (
        SELECT HS1.ID ID1, HS1.name name1, HS1.grade grade1, HS2.ID ID2, HS2.name name2, HS2.grade grade2
        FROM Highschooler HS1
            JOIN Likes ON Likes.ID1 = HS1.ID
            JOIN Highschooler HS2 ON Likes.ID2 = HS2.ID
        WHERE NOT EXISTS (SELECT * FROM Friend WHERE ID1 = HS1.ID AND ID2 = HS2.ID)
    ) LikesNotFriends
    JOIN Friend ON Friend.ID1 = LikesNotFriends.ID1
    JOIN Highschooler HS3 ON Friend.ID2 = HS3.ID
WHERE Friend.ID2 in (SELECT ID2 FROM Friend WHERE ID1 = LikesNotFriends.ID2);

-- Q8
-- Find the difference between the number of students in the school and the number of different first names.

SELECT COUNT(Highschooler.ID) - COUNT(DISTINCT Highschooler.name)
From Highschooler

-- Q9
-- Find the name and grade of all students who are liked by more than one other student.

Select Highschooler.name, Highschooler.grade
FROM Highschooler
    JOIN (
        SELECT Likes.ID2
        FROM Likes
        GROUP BY Likes.ID2
        HAVING COUNT(Likes.ID1) > 1
    ) PopPPL ON Highschooler.ID = PopPPL.ID2;