SELECT * FROM FCT_RATINGS
ORDER BY RATING_TIMESTAMP DESC
LIMIT 5;

select * from fct_movie_with_tags;

select * from snapshots.snap_tags
where user_id = 18
order by user_id, dbt_valid_from desc;

update src_tags
set tag = 'Mark Waters return', tag_timestamp = CAST(current_timestamp() AS TIMESTAMP_NTZ)
where user_id = 18;




CREATE OR REPLACE TABLE movie_analysis AS (WITH ratings_summary AS (
    SELECT
        movie_id,
        AVG(rating) AS average_rating,
        COUNT(*) AS total_ratings
    FROM
        MOVIELENS.DEV.fct_ratings
    GROUP BY
        movie_id
    HAVING
        COUNT(*) > 100 -- ONLY movies WITH AT LEAST 100 ratings
)
SELECT
    m.movie_title,
    rs.average_rating,
    rs.total_ratings
FROM
    ratings_summary rs
    JOIN MOVIELENS.DEV.dim_movies
    m
    ON m.movie_id = rs.movie_id
ORDER BY
    rs.average_rating DESC);


SELECT * FROM movie_analysis;