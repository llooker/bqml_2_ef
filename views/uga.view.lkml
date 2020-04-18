view: uga {
  sql_table_name: (SELECT * FROM `graphic-theory-197904.google_sheet_stock.uga` WHERE date is not null)
    ;;

  dimension: close {
    type: number
    sql: ${TABLE}.Close ;;
  }

  dimension: date {
    type: date
    datatype: date
    sql: PARSE_DATE('%m/%d/%Y',${TABLE}.Date) ;; #11/14/2017 16:00:00
  }

  dimension: high {
    type: number
    sql: ${TABLE}.High ;;
  }

  dimension: low {
    type: number
    sql: ${TABLE}.Low ;;
  }

  dimension: open {
    type: number
    sql: ${TABLE}.Open ;;
  }

  dimension: symbol {
    type: string
    sql: ${TABLE}.Symbol ;;
  }

  dimension: volume {
    type: number
    sql: ${TABLE}.Volume ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
