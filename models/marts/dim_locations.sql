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
        loc.restaurant_locality,    
        loc.locality_description,  
        loc.city,
        loc.restaurant_address,  
        loc.zipcode,
        loc.latitude,
        loc.longitude,
        coalesce(c.country, 'Unknown Country') as country_name,
        loc.row_ingested_at    

    from locations loc
    left join countries c 
        on loc.country_id = c.country_code
)

select * from final
