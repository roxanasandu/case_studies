
view: user_order_facts_ndt {
  derived_table: {
    explore_source: order_items {
      column: first_order_date {}
      column: latest_order_date {}
      column: user_id {}
      column: count_of_orders {}
      column: total_sale_price {}
      column: average_spend_per_customer {}
      column: latest_website_visit {}
    }
  }
  dimension: first_order_date {
    type: date
  }
  dimension: latest_order_date {
    type: date
  }
  dimension: user_id {
    primary_key: yes
    type: number
  }
  dimension: count_of_orders {
    type: number
  }
  dimension: total_sale_price {
    value_format: "$#,##0.00"
    type: number
  }
  dimension: average_spend_per_customer {
    value_format: "$#,##0.00"
    type: number
  }
  dimension: latest_website_visit {
    type: date
  }
  dimension: is_active_user {
    type: yesno
    sql: ${days_since_last_order} <= 90 ;;
  }

  dimension: days_since_last_order {
    type: duration_day
    sql_start: ${latest_order_date} ;;
    sql_end: CURRENT_DATE ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql:  ${count_of_orders} >1 ;;
  }

  # To make buckets, use type: tier

  dimension: orders_tiered {
    type: tier
    sql: ${count_of_orders} ;;
    tiers: [2,5,7,10]
    style: integer
  }

  dimension: revenue_tiered {
    type: tier
    sql: ${total_sale_price} ;;
    tiers: [4.99,19.99,50,100,500,1000]
    style: relational
    value_format_name: usd
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${count_of_orders} ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${count_of_orders} ;;
  }

  measure: total_lifetime_revenue {
    value_format_name: usd
    type: sum
    sql: ${total_sale_price} ;;
  }

  measure: average_lifetime_revenue {
    value_format_name: usd
    type: average
    sql: ${average_spend_per_customer} ;;
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: max_website_visit {
    type: date
    sql: MAX(${latest_website_visit} ;;
}
}
