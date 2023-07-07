###  Period over Period Method 8: Compare any period to any other period

# the most complex implementation, but also the most flexible

#### ------------ VIEWS TO LEAVE ALONE  ------------ ###
# This view sets up the config (doesn't need editing)

view: pop {
  sql_table_name: (SELECT NULL) ;;
  view_label: "_PoP"

### ------------ (HIDDEN) FILTERS TO CUSTOMIZE THE APPROACH ------------


# Choose a date range to filter on
  filter: date_filter  {
    label: "1. Date Range"
    hidden: yes
    type: date
    convert_tz: no
  }

# A second filter to choose number of past periods. Defaults to 1 if this is not selected
  filter: over_how_many_past_periods {
    label: "Override past periods"
    description: "Apply this filter to add past periods to compare to (from the default of current vs 1 period ago)"
    type: number
    default_value: "<=1"
  }


# # Choose how to break the range down - normally done with a parameter but here is a dimension
#   dimension: within_period_type {
#     label: "2. Break down date range by"
#     hidden: yes
#     type: string
# #Using case just to get friendlier UI experience in filters. Otherwise, could have a no-sql filter field
#     case: {
#       when: {
#         sql: {% parameter pop.within_period_type %}='quarter' ;;
#         label: "quarter"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='month' ;;
#         label: "month"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='week' ;;
#         label: "week"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='day' ;;
#         label: "day"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='hour' ;;
#         label: "hour"
#       }
#     }
#   }

  parameter: within_period_type {
    label: "2. Break down date range by"
    # hidden: yes
    type: unquoted
    allowed_value: {
      label: "quarter"
      value: "quarter"
    }
    allowed_value: {
      label: "month"
      value: "month"
    }
    allowed_value: {
      label: "week"
      value: "week"
    }
    allowed_value: {
      label: "day"
      value: "day"
    }
    allowed_value: {
      label: "hour"
      value: "hour"
    }
  }

# Choose the previous period
# # Again we use a dimension here instead of a parameter
#   dimension: over_period_type {
#     label: "3. Compare over"
#     hidden: yes
#     type: string
# #Using case just to get friendlier UI experience in filters. Otherwise, could have a no-sql filter field
#     case: {
#       when: {
#         sql: {% parameter pop.over_period_type %}='year' ;;
#         label: "year"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='quarter' ;;
#         label: "quarter"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='month' ;;
#         label: "month"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='week' ;;
#         label: "week"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='day' ;;
#         label: "day"
#       }
#     }
#   }


  parameter: over_period_type {
    label: "3. Compare over"
    hidden: yes
    type: unquoted
    allowed_value: {
      label: "year"
      value: "year"
    }
    allowed_value: {
      label: "quarter"
      value: "qurater"
    }
    allowed_value: {
      label: "month"
      value: "month"
    }
    allowed_value: {
      label: "week"
      value: "week"
    }
    allowed_value: {
      label: "day"
      value: "day"
    }
  }

### ------------ DIMENSIONS WE WILL ACTUALLY PLOT ------------


# This is the dimension we will plot as rows
# This version is always ordered correctly
  dimension: reference_date {
    hidden: yes
#type: date_time <-- too aggressive with choosing your string formatting for you
#type: date <-- too aggressive with truncating the time part
#convert_tz: no
#type: nothing <-- just right
    sql: DATE_TRUNC(
          DATE_ADD(DATE({% date_end pop.date_filter %}), INTERVAL 0 - ${within_periods.n} {% parameter pop.within_period_type %})
          , {% parameter pop.within_period_type %});;
  }

# This is the version we will actually plot in the data with nice formatting
  dimension: reference_date_formatted {
    type: string
    order_by_field: reference_date
    label: "Reference date"
    sql:
    --TO_CHAR(
    CAST(${reference_date} AS STRING FORMAT
          (CASE '{% parameter pop.within_period_type %}'
           WHEN 'year' THEN 'YYYY'
            WHEN 'month' THEN 'MON YY'
            WHEN 'quarter' THEN 'YYYY"Q"Q'
            WHEN 'week' THEN 'MM/DD/YY' --or 'YYYY"W"WW' or 'YY-MM"W"W'
            WHEN 'day' THEN 'MM/DD/YY'
            WHEN 'hour' THEN 'MM/DD HHam'
          ELSE 'MM/DD/YY'
          END)
          )
          ;;}


  # This is the dimension we will plot as pivots
      dimension: over_periods_ago  {
        label: "Prior Periods"
        description: "Pivot me!"
        sql: CASE ${over_periods.n}
                WHEN 0 THEN 'Current '||'{% parameter pop.over_period_type %}'
                WHEN 1 THEN ${over_periods.n}||' '||'{% parameter pop.over_period_type %}' || ' prior'
                ELSE        ${over_periods.n}||' '||'{% parameter pop.over_period_type %}' || 's prior'
                END;;
        order_by_field: over_periods.n
      }
    }
