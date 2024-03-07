SELECT * INTO appleStore_description_combined
FROM
(
    SELECT * FROM appleStore_description1$
    UNION ALL
    SELECT * FROM appleStore_description2$
    UNION ALL
    SELECT * FROM appleStore_description3$
    UNION ALL
    SELECT * FROM appleStore_description4$
) AS combined_data

--**EXPLORATORY DATA ANALYSIS**

-- Check the number of unique apps in both tablesAppleStore

Select Count(DISTINCT ID) AS UniqueAppIDs
FROM AppleStore$

Select Count(DISTINCT ID) AS UniqueAppIDs
FROM dbo.appleStore_description_combined

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore$
WHERE track_name is Null Or user_rating is null or prime_genre is null

SELECT COUNT(*) AS MissingValues
FROM dbo.appleStore_description_combined
WHERE app_desc is null

-- Find out the number of apps per genre

Select prime_genre, COUNT(*) As NumApps
FROM Applestore$
GROUP BY prime_genre
ORDER BY NumApps DESC

-- Get overview of apps ratings

SELECT min(user_rating) AS MinRating,	
	   max(user_rating) AS MaxRating,
	   avg(user_rating) AS AvgRating
FROM AppleStore$

-- **Data Analysis**

-- Determine whether paid apps have higher ratings than free apps

SELECT 
    CASE 
		WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
    END AS App_Type,
    AVG(user_rating) AS Avg_Rating
FROM 
    appleStore$
GROUP BY 
    CASE 
        WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
    END

-- Check if apps with more supported languages have higher ratings

SELECT
	CASE
		WHEN lang_num < 10 THEN '<10 languages'
		WHEN lang_num Between 10 and 30 THEN '10 languages'
		ELSE '>30 languages'
	END AS language_bucket,
	avg(user_rating) AS Avg_Rating
FROM AppleStore$
GROUP BY 
	CASE
		WHEN lang_num < 10 THEN '<10 languages'
		WHEN lang_num Between 10 and 30 THEN '10 languages'
		ELSE '>30 languages'
	END
ORDER BY Avg_Rating DESC

-- Check genres with low ratings

SELECT TOP 10
	   prime_genre,
	   avg(user_rating) AS Avg_Rating
FROM AppleStore$
GROUP BY prime_genre
ORDER BY Avg_Rating ASC

-- Check If there is correlation between the lenght of the app descripton and the user rating

SELECT
	CASE
		WHEN LEN(b.app_desc) <500 THEN 'Short'
		WHEN LEN(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
		ELSE 'Long'
	END AS description_lenght_bucket,
	avg(a.user_rating) AS Avg_Rating

FROM AppleStore$ AS A
JOIN appleStore_description_combined AS B ON a.id = b.id
GROUP BY
	CASE
		WHEN LEN(b.app_desc) <500 THEN 'Short'
		WHEN LEN(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
		ELSE 'Long'
	END
ORDER BY Avg_rating DESC

-- Check the top-rated apps for each genre

SELECT
	prime_genre,
	track_name,
	user_rating
FROM
	(
	SELECT
	prime_genre,
	track_name,
	user_rating,
	RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
	FROM AppleStore$
	) AS A
WHERE a.rank = 1

-- CONCLUSION 
	-- PAID APPS HAVE BETTER RATINGS = "Paid apps have achieved slightly higher ratings than free counter parts, users who pay for an app percived higher value and higher engagement, leading consideration charging money for apps."
	-- APPS SUPPORTING BetWEEN 10 AND 30 LANGUAGES HAVE BETTER RATINGS = "This has the highest average quality rating so its not about the quantity of the language more like focusing on the right languages"
	-- FINANCE AND BOOK APPS hAVE LOW RATINGS = "Users needs are not being fully met. This can represent a market opportunity because if you can create a quality app that addresses the user needs better than the current offering there's a potential for higher ratings."
	-- APPS WITH LONGER DESCRIPTION HAVE BETTER RATINGS = "Detailed desciption can set clear expectation usage increases the satisfaction of the users."
	-- A NEW APP SHOULD AIM FOR AN AVERAGE RATING ABOVE 3.5 = "The Average of the apps is 3.5 in order to stand out we should aim higher."
	-- GAMES AND ENTERTEINMENT HAVE HIGH COMPETITION = "This catergory is saturated so it may be challenging to enter this spaces due to high competition.However this also shows a high user demand in these categories."

-- END
