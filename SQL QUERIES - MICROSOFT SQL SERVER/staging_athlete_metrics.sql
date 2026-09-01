-- Create staging table and import csv file to it.
create Table staging_athlete_metrics (
 Athlete_ID       VARCHAR(50),
 Sport_Type     VARCHAR(50),
 Session_Date      VARCHAR(50),
 Heart_Rate_BPM  VARCHAR(255),
 Respiratory_Rate_BPM        VARCHAR(100),
 Skin_Temperature_C          VARCHAR(100),
 Blood_Oxygen_Level_Percent    VARCHAR(255),
 Impact_Force_Newtons        VARCHAR(100),
 Cumulative_Fatigue_Index          VARCHAR(50),
 Activity_Type        VARCHAR(50),
 Duration_Minutes       VARCHAR(50),
 Injury_Risk_Score          VARCHAR(50),
 Injury_Occurred		VARCHAR(50)
 
 );
 
select * from staging_athlete_metrics sam 

SELECT TOP(20) * FROM staging_athlete_metrics sam;

SELECT COUNT(*) as Total_Rows from staging_athlete_metrics sam;

SELECT Sport_Type, COUNT(*) as Session_Count FROM staging_athlete_metrics sam 
GROUP BY sam.Sport_Type
ORDER BY Session_Count DESC;

SELECT Activity_Type, COUNT(*) as Session_Count FROM staging_athlete_metrics sam 
GROUP BY sam.Activity_Type
ORDER BY Session_Count DESC;

SELECT
    Athlete_ID,
    Session_Date,
    Sport_Type,
    Activity_Type,
    COUNT(*) AS Duplicate_Count
FROM staging_athlete_metrics
GROUP BY
    Athlete_ID,
    Session_Date,
    Sport_Type,
    Activity_Type
HAVING COUNT(*) > 1
ORDER BY
    Duplicate_Count DESC;

SELECT DISTINCT Sport_Type FROM staging_athlete_metrics;
SELECT DISTINCT Activity_Type FROM staging_athlete_metrics;
SELECT COUNT(*) as Null_Session_Dates FROM staging_athlete_metrics WHERE Session_Date IS NULL;

Select COUNT(*) from staging_athlete_metrics sam;
