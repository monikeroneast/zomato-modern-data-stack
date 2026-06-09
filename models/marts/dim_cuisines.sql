with cuisines as (
    select * from {{ ref('stg_cuisines') }}
),

final as (
    select
        -- Generate a unique hash key for this long-format combination
        md5(cast(coalesce(cast(restaurant_id as varchar), '') || '-' || coalesce(cast(cuisine_name as varchar), '') as varchar)) as cuisine_key,
        restaurant_id,
        restaurant_name,
        cuisine_name,
<<<<<<< HEAD
        row_ingested_at,
       
=======
        row_ingested_at
>>>>>>> origin/main
    from cuisines
)

select * from final
