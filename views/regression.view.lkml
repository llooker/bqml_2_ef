##### Step 1 -- Raw Data #######
explore: uga_1 {
  from: uga
}
view: uga {
  sql_table_name: (SELECT *, 90 as temp FROM `graphic-theory-197904.google_sheet_stock.uga` WHERE date is not null)
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

  dimension: now {
    type: date
    expression: now() ;;
  }

  dimension: now_diff {
    type: duration_day
    datatype: date
    sql_end: ${date::date} ;;
    sql_start: ${now::date} ;;
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

  dimension: temp { type: number }

  measure: count {
    type: count
    drill_fields: [date, volume]
  }
}
explore: uga { hidden: yes }


##### Step 2 -- filter raw data as trainig input #######

view: predictions_base {
  derived_table: {
    explore_source: uga {
      column: date {}
      column: now_diff {}
      column: close {}
    }
  }
  dimension: now_diff {}
  dimension: close {type: number}
  dimension: high {}
  dimension: low {}
  dimension: open {}
  dimension: volume {}
  dimension: temp {}
}

view: training_input {
  extends: [predictions_base]
  derived_table: {
    explore_source: uga {
      column: now_diff {}
      column: date {}
      column: close {}
      column: open {}
      column: high {}
      column: low {}
      column: volume {}
      column: temp {}
      filters: {
        field: uga.date
        value: "30 days ago for 30 days"
      }
    }
  }
}

### Step 3 -- Use training data to create a model ##

view: future_purchase_model {
  derived_table: {

    # persist_for: "24 hours"
    sql_trigger_value: select 1 ;;
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='LINEAR_REG'
        , labels=["close"]
        ) AS
      SELECT
         date, now_diff, close, temp, {{ _filters['union_predict.training_label'] }}
      FROM ${training_input.SQL_TABLE_NAME};;
  }
  dimension: test {sql: 1 ;;}
}

explore:future_purchase_model  {}

### Step 4 -- create a calendar table of future data (which also btw includes the other independent variables....)  ####
view: future_dates {
  derived_table: {
    sql:
      SELECT
        CAST(DATE_ADD(CURRENT_DATE(), INTERVAL 1* n DAY) as TIMESTAMP) as date,
        CAST(TIMESTAMP_DIFF(CAST((DATE(TIMESTAMP_TRUNC(CAST(CAST(DATE_ADD(CURRENT_DATE(), INTERVAL 1* n DAY)  AS TIMESTAMP) AS TIMESTAMP), DAY)))  AS TIMESTAMP), CAST((DATE(TIMESTAMP_TRUNC(CAST(CURRENT_TIMESTAMP AS TIMESTAMP), DAY)))  AS TIMESTAMP), DAY) AS INT64) AS now_diff,
        {{ _filters['union_predict.slider_temp'] }} as temp,
       {% if union_predict.volatility_scenario._parameter_value == "'high'" %}  1415149 {% elsif union_predict.volatility_scenario._parameter_value == "'medium'"%} 50454 {% else %} 1282 {% endif %} as volume,
        {% if union_predict.volatility_scenario._parameter_value == "'high'" %} 15 {% elsif union_predict.volatility_scenario._parameter_value == "'medium'"%} 20 {% else %} null {% endif %} as open,
        {% if union_predict.volatility_scenario._parameter_value == "'high'" %} 40 {% elsif union_predict.volatility_scenario._parameter_value == "'medium'"%} 20 {% else %} null {% endif %} as high,
        {% if union_predict.volatility_scenario._parameter_value == "'high'" %} 9 {% elsif union_predict.volatility_scenario._parameter_value == "'medium'"%} 12 {% else %} null {% endif %} as low,
      FROM UNNEST(GENERATE_ARRAY(0,100,1)) n
      WHERE
      1=1
      AND DATE_ADD(CURRENT_DATE(), INTERVAL 1* n DAY) <= DATE_ADD(current_Date(), INTERVAL {{ _filters['union_predict.slider_prediction_horizon'] }} day)
       ;;
  }





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
  dimension: temp {}


}
explore: future_dates {}

# view: future_input {
#   derived_table: {
#     explore_source: future_dates {
#       column: now_diff { field: future_dates.now_diff}
#       column: date { field: future_dates.dt}
#       column: volume {}
#       column: open {}
#       column: low {}
#       column: high {}
#       filters: {
#         field: future_dates.dt
#         value: "0 days ago for 30 days"
#       }
#     }
#   }
# }

#### Step 5 -- generate a table of output predictions using the model #####

view: future_purchase_prediction {
  derived_table: {
    sql: SELECT * FROM ml.PREDICT(
          MODEL ${future_purchase_model.SQL_TABLE_NAME},
          (SELECT * FROM ${future_dates.SQL_TABLE_NAME}))
          ;;
  }
  # (SELECT * FROM ${future_input.SQL_TABLE_NAME}))
  dimension: now_diff {type: number}
  dimension: date {type: date datatype: date}
  dimension: predicted_close {
    type: number
  }
}

explore: future_purchase_prediction {}


### Step 6 -- layer the historical data with the future / predicitions data.

view: union_predict {
  derived_table: {
    sql:
    SELECT date, now_diff, close, 0 as future FROM ${predictions_base.SQL_TABLE_NAME}
    UNION ALL
    SELECT date, now_diff, predicted_close, 1 as future  FROM ${future_purchase_prediction.SQL_TABLE_NAME}
    ;;
  }
  dimension: now_diff { type: number }
  dimension: close {
    type: number
  }
  dimension: future {
    type: number
  }
  dimension: date {
    label: "date"
    type: date
    datatype: date
    sql: date(${TABLE}.date) ;;
  }

  measure: max_of_close_current {
    type: max
    sql: ${close};;
    filters: [future: "0"]
    value_format_name: usd
  }

  measure: max_of_close_future {
    type: max
    sql: ${close};;
    filters: [future: "1"]
    value_format_name: usd
    action: {
      label: "Manually Override Prediction"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Updated Prediction"
        required: yes
      }
    }
    action: {
      label: "Set Alert/Reminder"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Alert Threshold"
        required: no
      }
      form_param: {
        name: "Reminder Date"
        required: no
      }
    }
  }

  filter: training_label {
    suggestions: ["open"]
  }

  filter: slider_low {
    type: number
  }

  filter: slider_high {
    type: number
  }

  filter: slider_open {
    type: number
  }

  filter: slider_temp {
    type: number
  }

  filter: slider_prediction_horizon {
    type: number
  }


  parameter: volatility_scenario {
    allowed_value: {
      label: "high_volatility"
      value: "high"
    }
    allowed_value: {
      label: "medium_volatility"
      value: "medium"
    }
    allowed_value: {
      label: "low_volatility"
      value: "low"
    }

  }



}

explore: union_predict {
  always_filter: {
    filters: [slider_temp: "90", volatility_scenario: "low", slider_prediction_horizon: "30"]

  }


}
