{{
    config(
        materialized='ephemeral'
    )
}}
-- It does not create a physical table or view in the target database

WITH movies AS (
    SELECT * FROM {{ ref('dim_movies') }}
),

tags AS (
    SELECT * FROM {{ ref('dim_genome_tags') }}
),

scores AS (
    SELECT * FROM {{ ref('fct_genome_scores') }}
)

SELECT
    m.movie_id,
    m.movie_title,
    m.genres,
    t.tag_name,
    s.relevance_score
FROM movies m
LEFT JOIN scores s ON m.movie_id = s.movie_id
LEFT JOIN tags t ON t.tag_id = s.tag_id