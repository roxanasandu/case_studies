view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: order_created {
    type: date_time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: gross_revenue {
    hidden: yes
    type: number
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

#### custom dimentions


  dimension: age_groups {
    type: string
    sql: CASE
              WHEN ${users.age}  < 0 THEN 'Below 0'
              WHEN ${users.age}  < 10 THEN '0 to 9'
              WHEN ${users.age}  < 20 THEN '10 to 19'
              WHEN ${users.age}  < 30 THEN '20 to 29'
              WHEN ${users.age}  < 40 THEN '30 to 39'
              WHEN ${users.age}  < 50 THEN '40 to 49'
              WHEN ${users.age}  < 60 THEN '50 to 59'
              WHEN ${users.age}  < 70 THEN '60 to 69'
              WHEN ${users.age}  >= 70 THEN '70 or Above'
              ELSE 'Undefined'
            END ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: number_of_returned_items {
    type: count_distinct
    sql: ${id} ;;
    filters: [status: "Returned"]
  }

  measure: item_return_rate {
    type: number
    sql: 1.0*${number_of_returned_items}/${count} ;;
    value_format_name: percent_0
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }


  measure: avg_sales_price {
    type: average
    sql: ${sale_price}  ;;
    value_format_name: usd
  }


  measure: cumulative_sales {
    type: running_total
    sql: ${total_sale_price};;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    type: sum
    sql: ${gross_revenue} ;;
    filters: [status: "-Cancelled,-Returned"]
    value_format_name: usd
  }

  measure: average_gross_margin {
    type: average
    sql: ${gross_revenue} ;;
    filters: [status: "-Cancelled,-Returned"]
    value_format_name: usd
  }

  measure: total_gross_margin_amount {
    type: number
    sql: ${total_gross_revenue} - ${inventory_items.total_cost} ;;
    value_format_name: usd
  }

  measure: user_with_returns {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
  }

  measure: percent_of_users_with_returns {
    type: number
    sql: 1.0*${user_with_returns}/${users.count} ;;
    value_format_name: percent_0
  }

  measure: average_spend_per_customer {
    type: number
    sql: 1.0*${total_sale_price}/${users.count} ;;
    value_format_name: usd
  }

  measure: first_order_date {
    type: date
    sql: MIN(${created_date}) ;;
  }

  measure: latest_order_date {
    type: date
    sql: MAX(${created_raw}) ;;
  }

  measure: latest_website_visit {
    type: date
    sql: MAX(${events.created_raw}) ;;
  }

  measure: spend_per_user {
    view_label: "Order Items"
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / NULLIF(${users.count},0) ;;
  }

  measure: orders_per_user {
    view_label: "Order Items"
    type: number
    value_format_name: decimal_2
    sql: 1.0 * ${count} / NULLIF(${users.count},0) ;;
  }

  measure: count_of_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }



#  dimension: average_orders_per_user_dim {
 #   #hidden: yes
  #  type: string
   # sql: ${average_orders_per_user};;
#  }


 # measure: order_buckets {
  #  type: number
   # sql: CASE
    #          WHEN ${average_orders_per_user} = 1  THEN '1 Order'
     #         WHEN ${average_orders_per_user} = 2 THEN '2 Orders'
      #        WHEN ${average_orders_per_user} <= 5 THEN '3-5 Orders'
       #       WHEN ${average_orders_per_user} <= 9 THEN '6-9 Orders'
        #      WHEN ${average_orders_per_user} > 10 THEN '10+ Orders'
         #     ELSE 'Undefined'
          #  END ;;
  #}



  # measure: average_gross_margin_amount {
  #   type: number
  #   sql: ${total_gross_revenue} - ${inventory_items.total_cost} ;;
  #   value_format_name: usd
  # }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
