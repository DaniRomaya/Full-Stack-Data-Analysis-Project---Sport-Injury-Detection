-- QUESTION 1:
-- Where does injury risk concentrate? Which sport/activity combinations should coaches monitor most closely?"

-- Injury Rate for each sport type based on total sessions and total injuries
SELECT 
	dst.Sport_Type,
	COUNT(fs.Session_ID) as 
Total_Sessions, 
	SUM(fs.Injury_Occurred) as 
Total_Injuries, 
CAST(
	CAST(SUM(fs.Injury_Occurred) AS decimal(18, 4))
		/ NULLIF (COUNT(fs.Session_ID), 0) * 100 AS decimal(10,2)
) AS Injury_Rate_Percentage 
FROM dim_sport_type dst
JOIN fact_sessions fs on fs.Sport_Type_ID = dst.Sport_Type_ID
GROUP BY dst.Sport_Type
ORDER BY Total_Injuries DESC;

-- Injury Rate for each activity type based on total sessions and total injuries
SELECT
	da.Activity_Type,
	COUNT(fs.Session_ID) as
Total_Sessions,
	SUM(fs.Injury_Occurred) as
Total_Injuries,
CAST(
	CAST(SUM(fs.Injury_Occurred) AS decimal(18,4))
		/ NULLIF(COUNT(fs.Session_ID), 0) * 100 AS decimal(10,2)
) AS Injury_Rate_Percentage
FROM dim_activity da 
JOIN fact_sessions fs on fs.Activity_Type_ID = da.Activity_Type_ID 
GROUP BY da.Activity_Type 
ORDER BY Total_Injuries DESC; 

-- Injury Rate for each combination of sport and activity based on total sessions and total injries occurred
SELECT
    dst.Sport_Type,
    da.Activity_Type,
    COUNT(fs.Session_ID) as
Total_Sessions,
    SUM(fs.Injury_Occurred) as
Total_Injuries,
CAST(
    CAST(SUM(fs.Injury_Occurred) AS decimal(18, 4))
        / NULLIF (COUNT(fs.Session_ID),0) * 100 AS decimal(10,2)
)AS Injury_Rate_Percentage
FROM dim_sport_type dst
JOIN fact_sessions fs on fs.Sport_Type_ID = dst.Sport_Type_ID
JOIN dim_activity da  on da.Activity_Type_ID = fs.Activity_Type_ID
GROUP BY dst.Sport_Type, da.Activity_Type
ORDER BY Total_Sessions DESC, Total_Injuries DESC, Injury_Rate_Percentage  DESC

-- QUESTION 2:
-- Does higher impact force or cumulative fatigue index correlate with injury occurrence?

-- Comparison between Max, Min, and Avg of several metrics in correlation with injuries occurred.
SELECT 
	fs.Injury_Occurred,
	MAX(fs.Impact_Force_Newtons) AS MAX_Impact_Force,
	MIN(fs.Impact_Force_Newtons) AS MIN_Impact_Force,
	AVG(fs.Impact_Force_Newtons) AS AVG_Impact_Force,
	MAX(fs.Cumulative_Fatigue_Index) AS MAX_Cumulative_Fatigue_Index,
	MIN(fs.Cumulative_Fatigue_Index) AS MIN_Cumulative_Fatigue_Index,
	AVG(fs.Cumulative_Fatigue_Index) AS AVG_Cumulative_Fatigue_Index,
	MAX(fs.Heart_Rate_BPM) AS MAX_Heart_Rate_BPM,
	MIN(fs.Heart_Rate_BPM) AS MIN_Heart_Rate_BPM,
	AVG(fs.Heart_Rate_BPM) AS AVG_Heart_Rate_BPM,
	MAX(fs.Blood_Oxygen_Level_Percent) AS MAX_Blood_Oxygen_Level_Percent,
	MIN(fs.Blood_Oxygen_Level_Percent) AS MIN_Blood_Oxygen_Level_Percent,
	AVG(fs.Blood_Oxygen_Level_Percent) AS AVG_Blood_Oxygen_Level_Percent
FROM fact_sessions fs 
GROUP BY fs.Injury_Occurred; 

-- QUESTION 3: 
-- Has injury risk trended up/down over the dataset's date range, and are certain days/months worse?

-- Which months have the highest average injury risk score and injury rates?
SELECT 
	dd.year,
	dd.month_name,
	AVG(fs.Injury_Risk_Score) AS AVG_Injury_Risk_Score,
	CAST(
    CAST(SUM(fs.Injury_Occurred) AS decimal(18, 4))
        / NULLIF (COUNT(*),0) * 100 AS decimal(10,2)
) AS Injury_Rate_Percentage
FROM dim_date dd
JOIN fact_sessions fs  ON dd.Date_ID = fs.Date_ID
GROUP BY dd.year , dd.month_name, dd.month_num 
ORDER BY AVG_Injury_Risk_Score DESC;

-- Which days of the week have the highest average injury risk score and injury rates?
SELECT
	dd.Day_of_Week,
	AVG(fs.Injury_Risk_Score) AS AVG_Injury_Risk_Score,
	CAST(
    	CAST(SUM(fs.Injury_Occurred) AS decimal(18, 4))
        	/ NULLIF (COUNT(*), 0) * 100 AS decimal(10,2)
) AS Injury_Rate_Percentage
FROM dim_date dd 
JOIN fact_sessions fs  ON dd.Date_ID = fs.Date_ID
GROUP BY dd.Day_of_Week
ORDER BY
    CASE dd.Day_of_Week
        WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
    END;

-- Average injury and injury rate risk over the years.
SELECT
	dd.[year],
	dd.month_name,
	AVG(fs.Injury_Risk_Score) AS AVG_Injury_Risk_Score,
	CAST(
		CAST(SUM(Injury_Occurred) AS decimal(18, 4))
			/ NULLIF (COUNT(*), 0) * 100 AS decimal(10,2)
) AS Injury_Rate_Percentage
FROM dim_date dd
JOIN fact_sessions fs ON fs.Date_ID = dd.Date_ID
GROUP BY dd.year, dd.month_num, dd.month_name
ORDER BY dd.year , dd.month_num;

-- QUESTION 4:
-- Are there specific athletes with unusually high risk scores compared to the overall average?

-- Athletes with a higher injury risk score compared to the overall average injury risk score.
SELECT
    da.Athlete_ID,
    fs.Injury_Risk_Score,
    (SELECT AVG(Injury_Risk_Score) FROM fact_sessions) AS Overall_AVG_Injury_Risk_Score
FROM dim_athlete da
JOIN fact_sessions fs ON fs.Athlete_ID = da.Athlete_ID
WHERE fs.Injury_Risk_Score > (
    SELECT AVG(Injury_Risk_Score) FROM fact_sessions
)
ORDER BY fs.Injury_Risk_Score DESC;

