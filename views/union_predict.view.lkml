view: union_predict {
  derived_table: {
    sql:
    SELECT date, now_diff, close FROM ${predictions_base.SQL_TABLE_NAME}
    UNION ALL
    SELECT date, now_diff, predicted_close  FROM ${future_purchase_prediction.SQL_TABLE_NAME}
    ;;
  }
  dimension: now_diff { type: number }
  dimension: close {
    type: number
  }
  dimension: date {type: date datatype: date}

  filter: training_label {
    suggestions: ["open"]
  }

  filter: slider {
    type: number
  }

}
