- dashboard: predict
  title: Predict
  layout: newspaper
  embed_style:
    background_color: "#f6f8fa"
    show_title: false
    title_color: "#3a4245"
    show_filters_bar: true
    tile_text_color: "#3a4245"
    text_tile_text_color: ''
  elements:
  - title: price_prediction
    name: Price Prediction
    model: ef_2_bqml
    explore: union_predict
    type: looker_area
    fields: [union_predict.date, union_predict.max_of_close_current, union_predict.max_of_close_future]
    fill_fields: [union_predict.date]
    filters:
      union_predict.training_label: volume,open,high,low
      union_predict.slider_low: '6'
      union_predict.slider_high: '11'
      union_predict.slider_open: '9'
    sorts: [union_predict.date desc]
    limit: 500
    column_limit: 50
    dynamic_fields: [{measure: max_of_close, based_on: union_predict.close, type: max,
        label: Max of Close, expression: !!null '', value_format: !!null '', value_format_name: usd,
        _kind_hint: measure, _type_hint: number}]
    query_timezone: America/Los_Angeles
    x_axis_gridlines: true
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: false
    interpolation: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    color_application:
      collection_id: 5b121cce-cf79-457c-a52a-9162dc174766
      custom:
        id: 1a5aaadc-6121-4c75-8521-63fc467c1f44
        label: Custom
        type: discrete
        colors:
        - "#0178AD"
        - "#8DC73F"
      options:
        steps: 5
    y_axes: [{label: Max of Close, orientation: left, series: [{axisId: union_predict.max_of_close_current,
            id: union_predict.max_of_close_current, name: Max of Close Current}, {
            axisId: union_predict.max_of_close_future, id: union_predict.max_of_close_future,
            name: Max of Close Future}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    hide_legend: true
    series_types: {}
    series_colors: {}
    reference_lines: [{reference_type: margins, line_value: mean, range_start: max,
        range_end: min, margin_top: deviation, margin_value: mean, margin_bottom: deviation,
        label_position: right, color: "#000000", label: Mean}]
    discontinuous_nulls: true
    defaults_version: 1
    ordering: none
    show_null_labels: false
    listen:
      Market Conditions: union_predict.volatility_scenario
      Prediction Horizon: union_predict.slider_prediction_horizon
      Avg Future Temp: union_predict.slider_temp
    row: 0
    col: 0
    width: 24
    height: 9
  filters:
  - name: Prediction Horizon
    title: forecast_length
    type: field_filter
    default_value: '30'
    allow_multiple_values: true
    required: false
    model: ef_2_bqml
    explore: union_predict
    listens_to_filters: []
    field: union_predict.slider_prediction_horizon
  - name: Market Conditions
    title: market_volatility
    type: field_filter
    default_value: low
    allow_multiple_values: true
    required: false
    model: ef_2_bqml
    explore: union_predict
    listens_to_filters: []
    field: union_predict.volatility_scenario
  - name: Avg Future Temp
    title: avg_future_temp
    type: field_filter
    default_value: '90'
    allow_multiple_values: true
    required: false
    model: ef_2_bqml
    explore: union_predict
    listens_to_filters: []
    field: union_predict.slider_temp
