-- Movie    (mID int,   title text, year int,   director text);
-- Reviewer (rID int,   name text);
-- Rating   (rID int,   mID int,    stars int,  ratingDate date);

-- Q1
-- Find the names of all reviewers who rated Gone with the Wind.

SELECT DISTINCT Reviewer.name
FROM Reviewer JOIN Rating
    ON Reviewer.rID = Rating.rID
    JOIN Movie
    ON Rating.mID = Movie.mID
WHERE Movie.title = 'Gone with the Wind';

-- Q2
-- For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.

SELECT Reviewer.name, Movie.title, Rating.stars
FROM Reviewer join Rating
    ON Reviewer.rID = Rating.rID
    JOIN Movie
    ON Movie.mID = Rating.mID AND Movie.director = Reviewer.name;

-- Q3
-- Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)

Select *
From (
        SELECT Reviewer.name
        FROM Reviewer
    UNION
        SELECT Movie.title name
        FROM Movie
    ) names
ORDER BY name;

-- Q4
-- Find the titles of all movies not reviewed by Chris Jackson. 

SELECT Movie.title
FROM Movie
WHERE mID not in (
    SELECT mID
    From Rating
    JOIN Reviewer
    ON Reviewer.rID = Rating.rID
    WHERE Reviewer.name = 'Chris Jackson'
);

-- Q5
-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.

SELECT DISTINCT RV1.name, RV2.name
FROM (
        SELECT Reviewer.rID, Reviewer.name, Rating.mID
        FROM Reviewer
            JOIN Rating ON Reviewer.rID = Rating.rID
    ) RV1
    JOIN (
        SELECT Reviewer.rID, Reviewer.name, Rating.mID
        FROM Reviewer
            JOIN Rating ON Reviewer.rID = Rating.rID
    ) RV2 ON RV1.mID = RV2.mID
WHERE RV1.rID <> RV2.rID AND RV1.name < RV2.name

--WITH AS

WITH RatWithRev AS (
    SELECT Reviewer.rID, Reviewer.name, Rating.mID
    FROM Reviewer
        JOIN Rating ON Reviewer.rID = Rating.rID
)
SELECT DISTINCT RV1.name, RV2.name
FROM RatWithRev RV1
    JOIN RatWithRev RV2 ON RV1.mID = RV2.mID
WHERE RV1.rID <> RV2.rID AND RV1.name < RV2.name

-- Q6
-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.

SELECT Reviewer.name, Movie.title, Rating.stars
FROM Rating
    JOIN Movie
    ON Movie.mID = Rating.mID
    JOIN Reviewer
    ON Reviewer.rID = Rating.rID
Where rating.stars = (Select MIN(Rating.stars) from Rating);

-- Q7
-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.

SELECT Movie.title, avgRatings.avgRating
FROM Movie
    JOIN (
    Select AVG(Rating.stars) avgRating, mID
    From Rating
    GROUP BY Rating.mID
    ) avgRatings
    ON Movie.mID = avgRatings.mID
ORDER BY avgRatings.avgRating DESC, Movie.title;

-- Q8
-- Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)

SELECT Reviewer.name
FROM Reviewer JOIN (
    SELECT rID
    FROM Rating
    GROUP BY rID
    Having COUNT(mID) > 2
) ContributingRevs
    ON Reviewer.rID = ContributingRevs.rID;

-- without HAVING

SELECT Reviewer.name
FROM Reviewer JOIN (
    SELECT rID, COUNT(mID) RevCount
    FROM Rating
    GROUP BY rID
) ContributingRevs
    ON Reviewer.rID = ContributingRevs.rID
WHERE RevCount > 2;

-- without COUNT

SELECT Reviewer.name
FROM Reviewer JOIN (
    SELECT DISTINCT r1.rID
    FROM Rating r1
        JOIN Rating r2
        ON r1.rID = r2.rID
        JOIN Rating r3
        ON r1.rID = r3.rID
    WHERE NOT (r1.mID = r2.mID AND r1.ratingDate = r2.ratingDate)
        AND NOT (r1.mID = r3.mID AND r1.ratingDate = r3.ratingDate)
        AND NOT (r2.mID = r3.mID AND r2.ratingDate = r3.ratingDate)
) ContributingRevs
    ON Reviewer.rID = ContributingRevs.rID;

-- Q9
-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

SELECT Movie.title, Movie.director
FROM Movie
WHERE Movie.director in (
    SELECT movie.director
    FROM Movie
    GROUP BY Movie.director
    HAVING COUNT(mID) > 1
)
ORDER BY Movie.director, Movie.title;

-- without HAVING

SELECT Movie.title, Movie.director
FROM Movie join (
    SELECT movie.director, Count(mID) MovieCount
    FROM Movie
    GROUP BY Movie.director
) repeatedDirectors
ON Movie.director = repeatedDirectors.director
WHERE MovieCount > 1
ORDER BY Movie.director, Movie.title;

-- without COUNT

-- Q10
-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)

SELECT Movie.title, avgStars
From Movie JOIN (
    SELECT Rating.mID, AVG(Rating.stars) avgStars
    From Rating
    GROUP BY Rating.mID
) avgRating
    ON Movie.mID = avgRating.mID
Where avgRating.avgStars = (
    SELECT MAX(avgStars)
FROM (
        SELECT AVG(Rating.stars) avgStars
    From Rating
    GROUP BY Rating.mID
    ) avgRating
);

--WITH AS
WITH
    avgRating
    AS
    (
        SELECT Rating.mID, AVG(Rating.stars) avgStars
        From Rating
        GROUP BY Rating.mID
    )
SELECT Movie.title, avgStars
From Movie
    JOIN avgRating ON Movie.mID = avgRating.mID
Where avgRating.avgStars = (SELECT MAX(avgStars)
FROM avgRating );

-- Q11
-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)

SELECT Movie.title, avgStars
From Movie JOIN (
    SELECT Rating.mID, AVG(Rating.stars) avgStars
    From Rating
    GROUP BY Rating.mID
) avgRating
    ON Movie.mID = avgRating.mID
Where avgRating.avgStars = (
    SELECT MIN(avgStars)
FROM (
        SELECT AVG(Rating.stars) avgStars
    From Rating
    GROUP BY Rating.mID
    ) avgRating
);

--WITH AS
WITH
    avgRating
    AS
    (
        SELECT Rating.mID, AVG(Rating.stars) avgStars
        From Rating
        GROUP BY Rating.mID
    )
SELECT Movie.title, avgStars
From Movie
    JOIN avgRating ON Movie.mID = avgRating.mID
Where avgRating.avgStars = (SELECT MIN(avgStars)
FROM avgRating );

-- Q12
-- For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.

SELECT DISTINCT Movie.director, Movie.title, Rating.stars highestRating
FROM Movie
    JOIN Rating ON Movie.mID = Rating.mID
WHERE Movie.director is not NULL
    AND Rating.stars = (
        Select Max(Rating.stars)
        From Movie m
            JOIN Rating ON m.mID = Rating.mID
        WHERE m.director = Movie.director
    );
