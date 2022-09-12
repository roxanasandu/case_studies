connection: "thelook_ecommerce_cts_bq_instance"

# include all the views
include: "/data_views/**/*.view"
include: "/derived_tables/**/*.view"

include: "data_groups.lkml"

persist_with: default_datagroup

explore: distribution_centers {}

explore: etl_jobs {}

explore: user_order_facts_ndt {}

explore: events {
 # fields: [ALL_FIELDS*,-users.first_order_date]   ### similar to EXCEPT in BQ
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
  # join: order_items {    #### IS THIS CORRECT?
  #   type: left_outer
  #   sql_on: ${events.user_id} = ${order_items.user_id} ;;
  #   relationship: many_to_many
  # }
  # join: inventory_items {
  #   type: left_outer
  #   sql_on: ${events.user_id} -  ;;
  # }
}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {

  sql_always_where:
  {% if order_items.current_date_range._is_filtered %}
  {% condition order_items.current_date_range %} ${event_raw} {% endcondition %}

  {% if order_items.previous_date_range._is_filtered or order_items.compare_to._in_query %}
  {% if order_items.comparison_periods._parameter_value == "2" %}
  or
  ${event_raw} between ${period_2_start} and ${period_2_end}

  {% elsif order_items.comparison_periods._parameter_value == "3" %}
  or
  ${event_raw} between ${period_2_start} and ${period_2_end}
  or
  ${event_raw} between ${period_3_start} and ${period_3_end}


  {% elsif order_items.comparison_periods._parameter_value == "4" %}
  or
  ${event_raw} between ${period_2_start} and ${period_2_end}
  or
  ${event_raw} between ${period_3_start} and ${period_3_end}
  or
  ${event_raw} between ${period_4_start} and ${period_4_end}

  {% else %} 1 = 1
  {% endif %}
  {% endif %}
  {% else %} 1 = 1
  {% endif %};;

  # conditionally_filter: {filters: [order_items.age_groups: "20 to 29"]
  #                         unless: [order_items.status]}

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  join: events {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts_ndt {
    type: left_outer
    sql_on: ${order_items.user_id} = ${user_order_facts_ndt.user_id} ;;
    relationship: many_to_one
  }
}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

}

explore: users {}

# explore: order_items_extended {}
