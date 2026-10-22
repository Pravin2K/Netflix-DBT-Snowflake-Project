-- Snowflake user creation
-- Step 1: Use an admin role
USE ROLE ACCOUNTADMIN;

-- Step 2: Create the `transform` role and assign it to ACCOUNTADMIN
CREATE ROLE IF NOT EXISTS TRANSFORM;
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN;

-- Step 3: Create a default warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;

-- Step 4: Create the `dbt` user and assign to the transform role
CREATE USER IF NOT EXISTS dbt
  PASSWORD='dbtPassword123'
  LOGIN_NAME='dbt'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE_WH'
  DEFAULT_ROLE=TRANSFORM
  DEFAULT_NAMESPACE='MOVIELENS.RAW'
  COMMENT='DBT user used for data transformation';
ALTER USER dbt SET TYPE = LEGACY_SERVICE;
GRANT ROLE TRANSFORM TO USER dbt;

-- Step 5: Create a database and schema for the MovieLens project
CREATE DATABASE IF NOT EXISTS MOVIELENS;
CREATE SCHEMA IF NOT EXISTS MOVIELENS.RAW;

-- Step 6: Grant permissions to the `transform` role
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;
GRANT ALL ON DATABASE MOVIELENS TO ROLE TRANSFORM;
GRANT ALL ON ALL SCHEMAS IN DATABASE MOVIELENS TO ROLE TRANSFORM;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE MOVIELENS TO ROLE TRANSFORM;
GRANT ALL ON ALL TABLES IN SCHEMA MOVIELENS.RAW TO ROLE TRANSFORM;
GRANT ALL ON FUTURE TABLES IN SCHEMA MOVIELENS.RAW TO ROLE TRANSFORM;



CREATE OR REPLACE STORAGE INTEGRATION S3_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::984454382053:role/AWS_Storage_Integration'
  -- STORAGE_ALLOWED_LOCATIONS = ('s3://awsprk0947/Snowflake/');
  STORAGE_ALLOWED_LOCATIONS = ('s3://awsprk0947/Netflix/');
  desc storage integration s3_int

-- Create file format :
CREATE OR REPLACE FILE FORMAT NETFLIX_INGEST_DATA
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


--Create stages
CREATE OR REPLACE STAGE NETFLIXSTAGE
  STORAGE_INTEGRATION = S3_INT
  URL = 's3://awsprk0947/Netflix/';
  list @netflixstage;


  --Create table 
CREATE OR REPLACE TABLE raw_movies (
  movieId INTEGER,
  title STRING,
  genres STRING
);

list@netflixstage;

--Copy data from stage into table:
COPY INTO raw_movies
FROM '@NETFLIXSTAGE/movies.csv'
FILE_FORMAT = NETFLIX_INGEST_DATA
FORCE = TRUE;
SELECT * FROM raw_movies;
-------------------------------------------

--Create Table raw_rating and copying the data::
CREATE OR REPLACE TABLE raw_ratings (
  userId INTEGER,
  movieId INTEGER,
  rating FLOAT,
  timestamp BIGINT
);
COPY INTO RAW_RATINGS
FROM '@NETFLIXSTAGE/ratings.csv'
FILE_FORMAT = NETFLIX_INGEST_DATA;
SELECT * FROM RAW_RATINGS;
--------------------------------------------------

-- Load raw_tags
CREATE OR REPLACE TABLE raw_tags (
  userId INTEGER,
  movieId INTEGER,
  tag STRING,
  timestamp BIGINT
);
COPY INTO RAW_TAGS
FROM '@NETFLIXSTAGE/tags.csv'
FILE_FORMAT = NETFLIX_INGEST_DATA;
SELECT * FROM RAW_TAGS;
----------------------------------------------------------

---- Load raw_genome_scores
CREATE OR REPLACE TABLE raw_genome_scores (
  movieId INTEGER,
  tagId INTEGER,
  relevance FLOAT
);
COPY INTO raw_genome_scores
FROM '@NETFLIXSTAGE/genome-scores.csv'
FILE_FORMAT = NETFLIX_INGEST_DATA;
SELECT * FROM raw_genome_scores;
--------------------------------------------------------------

-- Load raw_genome_tags
CREATE OR REPLACE TABLE raw_genome_tags (
  tagId INTEGER,
  tag STRING
);
COPY INTO raw_genome_tags
FROM '@NETFLIXSTAGE/genome-tags.csv'
FILE_FORMAT = NETFLIX_INGEST_DATA;
SELECT * FROM raw_genome_tags;
-------------------------------------------------------------

-- Load raw_links
CREATE OR REPLACE TABLE raw_links (
  movieId INTEGER,
  imdbId INTEGER,
  tmdbId INTEGER
);
COPY INTO raw_links
FROM '@NETFLIXSTAGE/links.csv'
FILE_FORMAT = NETFLIX_INGEST_DATA;
SELECT * FROM raw_links;
-------------------------------------------------------------


