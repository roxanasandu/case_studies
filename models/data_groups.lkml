datagroup: default_datagroup {
  sql_trigger: SELECT MAX(id) FROM etl_jobs;;
  max_cache_age: "1 hour"
}
