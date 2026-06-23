with restaurants as (
    select * from {{ ref('stg_restaurants') }}
),

final as (
    select
        restaurant_id,
        restaurant_name,
        has_online_delivery,
        is_delivering_now,
        has_table_booking,
        price_range,
        transaction_currency,
        row_ingested_at

    from restaurants
)

select * from final
