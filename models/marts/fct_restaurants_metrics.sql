with orders_source as (
    -- Read from your original staging orders file that contains the raw metrics
    select * from {{ ref('stg_orders') }}
),

countries as (
    -- Reference your working seed file
    select * from {{ ref('country_code') }}
),


final as (
    select
        -- Foreign Keys to join back to your dimensions (dim_locations, dim_restaurants, dim_cuisines)
        o.restaurant_id,
        o.country_id as country_code,

        -- Pulling text reference directly into the fact layer for easy slicing
        coalesce(c.country, 'Unknown Country') as country_name,
        
        -- Measurable Performance & Financial Metrics (The Facts)
        cast(o.average_cost_for_two as float) as average_cost_for_two,
        cast(o.price_range as integer) as price_range,
        cast(o.transaction_currency as string) as transaction_currency,
        cast(o.customer_rating as float) as customer_rating,   -- aggregate_rating: ex. 4.3
        cast(o.total_votes as integer) as total_votes,
        
        -- Metadata
        o.row_ingested_at as row_ingested_at
    from orders_source o
    left join countries c 
        on o.country_id = c.country_code
)

select * from final
