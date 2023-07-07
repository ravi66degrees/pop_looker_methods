###  Period over Period Method 8: Compare any period to any other period
# the most complex implementation, but also the most flexible
#### ------------ VIEWS TO EDIT  ------------ ###

view: pop_order_items_created {
  view_label: "Order Items (By created date)"
  sql_table_name: (
        SELECT
            DATE_TRUNC(created_at, {% parameter pop.within_period_type %}) as join_date,
            COUNT(*) as agg_1,
            SUM(sale_price) as agg_2
            -- FROM order_items
           FROM `looker-partners.thelook.order_items`
          GROUP BY 1
            ) ;;

  measure:  agg_1 {
    type:  number
    label: "Count"
    sql: SUM(${TABLE}.agg_1) ;;
  }
  measure:  agg_2 {
    type:  number
    label: "Total Sales"
    sql: SUM(${TABLE}.agg_2) ;;
  }
}
