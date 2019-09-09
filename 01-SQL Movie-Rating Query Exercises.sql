-- Movie    (mID int,   title text, year int,   director text);
-- Reviewer (rID int,   name text);
-- Rating   (rID int,   mID int,    stars int,  ratingDate date);

-- Q1
-- Find the titles of all movies directed by Steven Spielberg.

SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';

-- Q2
-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

SELECT Distinct year
From Movie join Rating
    ON Movie.mID = Rating.mID
WHERE stars > 3
ORDER By year;

-- Q3
-- Find the titles of all movies that have no ratings.

SELECT title
FROM Movie m
WHERE m.mID not in (SELECT mID
FROM Rating);

-- Q4
-- Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.

SELECT Distinct name
FROM Rating JOIN Reviewer
    ON Rating.rID = Reviewer.rID
WHERE ratingDate is NULL;

-- Q5
-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.

SELECT Reviewer.name, Movie.title, Rating.stars, Rating.ratingDate
FROM Rating
    JOIN Movie
    ON Movie.mID = Rating.mID
    JOIN Reviewer
    ON Reviewer.rID = Rating.rID
ORDER BY Reviewer.name, movie.title, Rating.stars;

-- Q6
-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.

SELECT Reviewer.name, Movie.title
FROM (SELECT R1.rID rID, R1.mID mID
    FROM Rating R1 JOIN Rating R2
        ON R1.rID = R2.rID
            AND R1.mID = R2.mID
    WHERE R2.ratingDate > R1.ratingDate
        AND R2.stars > R1.stars) repeated
    JOIN Movie
    ON Movie.mID = repeated.mID
    JOIN Reviewer
    ON Reviewer.rID = repeated.rID;

-- Q7
-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.

SELECT Movie.title, Highest.stars
FROM (
    SELECT max(stars) stars, mID
    FROM Rating
    GROUP BY Rating.mID
) Highest
    JOIN Movie
    ON Movie.mID = Highest.mID
ORDER BY Movie.title;

-- Q8
-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.

SELECT Movie.title, Diff.spread
FROM (
    SELECT (max(stars) - min(stars)) spread, mID
    FROM Rating
    GROUP BY Rating.mID
) Diff
    JOIN Movie
    ON Movie.mID = Diff.mID
ORDER BY Diff.spread desc, Movie.title;

-- Q9
-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)

SELECT (
    SELECT AVG(avgR)
    FROM (
        SELECT AVG(Rating.stars) avgR
        FROM Rating JOIN Movie
            ON Movie.mID = Rating.mID
        WHERE Movie.year < 1980
        GROUP BY Rating.mID
    ) avgRBefore
) -
(
    SELECT AVG(avgR)
    FROM (
        SELECT AVG(Rating.stars) avgR
        FROM Rating JOIN Movie
            ON Movie.mID = Rating.mID
        WHERE Movie.year > 1980
        GROUP BY Rating.mID
    ) avgRAfter
)
