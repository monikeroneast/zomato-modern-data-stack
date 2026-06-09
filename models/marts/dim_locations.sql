with locations as (
    select * from {{ ref('stg_locations') }}
),

countries as (
    select * from {{ ref('country_code') }}
),

final as (
    select
        loc.restaurant_id,
        loc.restaurant_name,
        loc.restaurant_locality,    -- Matches line 11 of your staging file
        loc.locality_description,  -- Matches line 15 of your staging file
        loc.city,
        loc.restaurant_address,     -- Matches line 10 of your staging file
        loc.zipcode,
        loc.latitude,
        loc.longitude,
        coalesce(c.country, 'Unknown Country') as country_name,
        loc.row_ingested_at       -- Matches line 16 of your staging file
    from locations loc
    left join countries c 
        on loc.country_id = c.country_code
)

select * from final
