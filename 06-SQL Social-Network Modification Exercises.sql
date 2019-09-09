-- Q1
-- It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

DELETE FROM Highschooler
WHERE grade = 12;

-- Q2
-- If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.


DELETE FROM Likes
WHERE ID2 in (
        SELECT F.ID2
        FROM Friend F
        WHERE F.ID1 = Likes.ID1
    )
    AND ID1 NOT in (
        SELECT L2.ID2
        FROM Likes L2
        WHERE L2.ID1 = Likes.ID2
    )

-- Q3
-- For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)

INSERT INTO Friend
    SELECT DISTINCT F1.ID1, F2.ID2
    FROM Friend F1
        JOIN Friend F2 ON F1.ID2 = F2.ID1
    WHERE F1.ID1 <> F2.ID2
        AND F1.ID1 NOT IN
        (
            SELECT ID2
            FROM Friend
            where Friend.ID1 = F2.ID2
        );