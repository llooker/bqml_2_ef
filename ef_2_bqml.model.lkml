connection: "bfw_bq"


include: "/views/*.view.lkml"


datagroup: bqml_datagroup {
  #retrain model every day
  max_cache_age: "1 hour"
  sql_trigger: SELECT CURRENT_DATE() ;;
}
