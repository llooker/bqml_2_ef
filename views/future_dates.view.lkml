
view: future_dates {
  derived_table: {
    sql:
      SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 1* n DAY) as dt, null as volume, null as open, null as high, null as low
      FROM UNNEST(GENERATE_ARRAY(0,100,1)) n
       ;;
  }


#replace null as low with {{ _filters['union_predict.slider'] }}
  dimension: dt {
    type: date
    datatype: date
    sql: ${TABLE}.dt ;;
  }

  dimension: now {
    type: date
    expression: now() ;;
  }

  dimension: now_diff {
    type: duration_day
    datatype: date
    sql_end: ${dt::date} ;;
    sql_start: ${now::date} ;;
  }

  dimension: volume {}
  dimension: open {}
  dimension: high {}
  dimension: low {}


}
