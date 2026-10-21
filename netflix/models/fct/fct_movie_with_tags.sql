WITH fct_movie_w_tag AS(
    SELECT * FROM {{ref('dim_movies_with_tags')}}
)

SELECT * FROM fct_movie_w_tag