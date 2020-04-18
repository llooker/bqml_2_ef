
view: future_dates {
  derived_table: {
    sql:
SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 1* n DAY) as dt
FROM UNNEST(GENERATE_ARRAY(0,100,1)) n
       ;;
  }

  dimension: dt {
    type: date
    datatype: date
    sql: ${TABLE}.dt ;;
  }
}
