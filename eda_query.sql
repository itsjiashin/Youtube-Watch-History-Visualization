--SQL queries used to do some exploratory data analysis in AWS Athena itself

-- Create the watch history table from the CSV file containing the preprocessed watch history stored in a S3 bucket
CREATE EXTERNAL TABLE IF NOT EXISTS `youtubewatchhistory`.`history` ( `channel_name` string, `date` date, `time` string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES ('field.delim' = ',')
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat' OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://aws-projects-bucket-kjs/youtube-watch-history/preprocessed-data/'
TBLPROPERTIES ( 'classification' = 'csv', 'skip.header.line.count' = '1'
)

-- Count the number of entries
SELECT count(*) AS total_videos_watched FROM history;

-- Count the number of videos watched every month from July 2025 to October 2025
SELECT MONTH(history.date) AS month, COUNT(*) AS total_vids_watched
FROM history
WHERE history.date IS NOT NULL
GROUP BY MONTH(history.date)
ORDER BY month;

-- Videos watched by weekday
SELECT 
  day_of_week(history.date) AS weekday,
  COUNT(*) AS total_videos_watched
FROM history
GROUP BY day_of_week(history.date)
ORDER BY weekday;

-- Videos watched by hour of day for each month
SELECT
  MONTH(date) AS month,
  CAST(SUBSTR(time, 1, 2) AS INTEGER) AS hour_of_day,
  COUNT(*) AS total_videos_watched
FROM history
GROUP BY MONTH(date), CAST(SUBSTR(time, 1, 2) AS INTEGER)
ORDER BY month, hour_of_day;
