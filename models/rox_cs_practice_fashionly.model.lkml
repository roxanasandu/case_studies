connection: "snowlooker"

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
