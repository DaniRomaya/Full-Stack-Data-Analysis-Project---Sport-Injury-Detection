
-- Creating dimension tables and fact table--------------------------------------------------------------------
CREATE TABLE dim_sport_type (
    Sport_Type_ID   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,    -- auto-incrementing surrogate key
    Sport_Type  VARCHAR(100),
);

CREATE TABLE dim_athlete (
	Athlete_ID INT NOT NULL PRIMARY KEY
	);

CREATE TABLE dim_activity (
	Activity_Type_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Activity_Type VARCHAR(100)
	);

CREATE TABLE dim_date (
	Date_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Session_Date DATE NOT NULL,
	Day_of_Week VARCHAR(10) NOT NULL,
	day_num         SMALLINT,
    month_num       SMALLINT,
    month_name      VARCHAR(10),
    quarter         SMALLINT,
    year            SMALLINT,
    is_weekend      BIT
)

CREATE TABLE fact_sessions (
	Session_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Athlete_ID VARCHAR(10) REFERENCES dim_athlete(Athlete_ID),
	Sport_Type_ID INT REFERENCES dim_sport_type(Sport_Type_ID),
	Activity_Type_ID INT REFERENCES dim_activity(Activity_Type_ID),
	Date_ID INT REFERENCES dim_date(Date_ID),
	Heart_Rate_BPM INT,
	Respiratory_Rate_BPM INT,
	Skin_Temperature_C Float,
	Blood_Oxygen_Level_Percent Float,
	Impact_Force_Newtons Float,
	Cumulative_Fatigue_Index Float,
	Duration_Minutes INT,
	Injury_Risk_Score Float,
	Injury_Occurred INT
);

--------------------------------------------------------------------------------------------------------------

-- Populate the dimension tables from staging table (deduplicated)
INSERT INTO dim_activity (Activity_Type)
SELECT DISTINCT Activity_Type FROM staging_athlete_metrics sam;

INSERT INTO dim_athlete (Athlete_ID)
SELECT DISTINCT Athlete_ID FROM staging_athlete_metrics sam;

INSERT INTO dim_date (Session_date, day_of_week, day_num, month_num, month_name, quarter, year, is_weekend)
SELECT DISTINCT
    CAST(Session_Date AS DATE),
    DATENAME(WEEKDAY, Session_Date),
    DAY(Session_Date),
    MONTH(Session_Date),
    DATENAME(MONTH, Session_Date),
    DATEPART(QUARTER, Session_Date),
    YEAR(Session_Date),
    CASE WHEN DATENAME(WEEKDAY, Session_Date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
FROM staging_athlete_metrics;

INSERT INTO dim_sport_type (Sport_Type)
SELECT DISTINCT Sport_Type from staging_athlete_metrics sam;

-------------------------------------------------------------------------------------------------------------------

-- Populate the fact table (joining staging back to new dimension IDs)
INSERT INTO fact_sessions ( 
Athlete_ID, 
Sport_Type_ID, 
Activity_Type_ID, 
Date_ID, 
Heart_Rate_BPM, 
Respiratory_Rate_BPM, 
Skin_Temperature_C,
Blood_Oxygen_Level_Percent,
Impact_Force_Newtons,
Cumulative_Fatigue_Index,
Duration_Minutes,
Injury_Risk_Score,
Injury_Occurred
)
SELECT 
s.Athlete_ID,
dsp.Sport_Type_ID,
dac.Activity_Type_ID,
dd.Date_ID,
s.Heart_Rate_BPM,
s.Respiratory_Rate_BPM,
s.Skin_Temperature_C,
s.Blood_Oxygen_Level_Percent,
s.Impact_Force_Newtons,
s.Cumulative_Fatigue_Index,
s.Duration_Minutes,
s.Injury_Risk_Score,
s.Injury_Occurred
FROM staging_athlete_metrics as s
JOIN dim_sport_type dsp ON s.Sport_Type = dsp.Sport_Type
JOIN dim_activity dac ON s.Activity_Type = dac.Activity_Type
JOIN dim_date dd ON CAST(s.Session_Date AS DATE) = dd.Session_date;

---------------------------------------------------------------------------------------------------------------

