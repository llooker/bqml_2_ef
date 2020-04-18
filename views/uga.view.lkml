view: uga {
  sql_table_name: `graphic-theory-197904.google_sheet_stock.uga`
    ;;

  dimension: close {
    type: number
    sql: ${TABLE}.Close ;;
  }

  dimension: date {
    type: string
    sql: ${TABLE}.Date ;;
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
