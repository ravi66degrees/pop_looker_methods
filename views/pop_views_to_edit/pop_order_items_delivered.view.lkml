###  Period over Period Method 8: Compare any period to any other period

# the most complex implementation, but also the most flexible

#### ------------ VIEWS TO EDIT  ------------ ###

#### ------------ EXTENSIBLE VERSION (Multiple dates)  ------------ ###
## This is what the above looks like if we scale it to work with multiple date fields
## We make one view per date and join them all to the model

view: pop_order_items_delivered {
  view_label: "Order Items (By delivered date)"
  sql_table_name: (SELECT
              DATE_TRUNC(order_items.shipped_at, {% parameter pop.within_period_type %}) as join_date,
              COUNT(*) as agg_1,
              SUM(order_items.sale_price) as agg_2
              FROM order_items
              WHERE {%condition pop_order_items_delivered.sale_price %}order_items.sale_price{% endcondition %}
              GROUP BY 1
              ) ;;
}
