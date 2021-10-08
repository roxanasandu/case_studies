
# If necessary, uncomment the line below to include explore_source.
# include: "rox_cs_practice_fashionly.model.lkml"

  view: custom_dimensions  {
    derived_table: {
      explore_source: order_items {
        column: average_orders_per_user {}
        column: id { field: users.id }
      }
    }
    dimension: orders_per_user {
      value_format: "#,##0.00"
      type: number
    }
    dimension: id {
      type: number
    }
  }
