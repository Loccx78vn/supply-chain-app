# Import the necessary modules with box::use
box::use(
  shiny[NS, callModule, showNotification,tagList,tags,reactive,req,debounce],
  DT[...],
  dplyr[filter, mutate, case_when, select],
  tidyr[pivot_longer],
  reactablefmtr[data_bars],
  magrittr[`%>%`],
  htmltools[div],
  stats[quantile],
  htmlwidgets[JS]
)

# Import the data from the database module
box::use(data/database,
         app/constants,
         app/logic/func_sales[status_PI.Index,gen_daily_data])

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-table-container",
      DTOutput(ns("table"))
    )
  )
}

#' @export
init_server <- function(id, df, region, warehouse) {
  callModule(server, id, df, region, warehouse)
}

#' @export
server <- function(input, output, session, df, region, warehouse) {
    
    # Preprocess data once and cache it
    daily_data <- reactive({
     gen_daily_data(df, region(), warehouse())
    })
    
    output$table <- renderDT({
      
      data<-daily_data()
      
      DT::datatable(
        data |> 
          select(c(flag_url, region, wh_code, date, sum, supply_good, status)),
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          autoWidth = TRUE,
          columnDefs = list(
            # Flag URL column
            list(
              targets = 0,
              title = "Country",
              render = JS("function(data, type, row, meta) {
          if (data && data != '') {
            return '<img src=\"' + data + '\" width=45 height=40 style=\"display: block; margin: auto;\">';
          } else {
            return '';
          }
        }")
            ),
        # Region column
        list(
          targets = 1,
          title = "Region"
        ),
        # Warehouse column
        list(
          targets = 2,
          title = "Warehouse"
        ),
        # Date column
        list(
          targets = 3,
          title = "Date"
        ),
        # Demand column
        list(
          targets = 4,
          title = "Demand"
        ),
        # Supply column
        list(
          targets = 5,
          title = "Supply (units)"
        ),
        # Status column
        list(
          targets = 6,
          title = "Status",
          render = JS("function(data, type, row, meta) {
          let color;
          switch(data) {
            case 'Bad':
              color = 'hsl(3, 69%, 50%)';
              break;
            case 'Good':
              color = 'hsl(154, 64%, 50%)';
              break;
            case 'Pass KPI':
              color = 'hsl(214, 45%, 50%)';
              break;
            case 'Okay':
              color = 'hsl(60, 100%, 50%)';
              break;
            default:
              color = '#777';
          }
          return '<div style=\"display: flex; align-items: center;\"><div style=\"width: 12px; height: 12px; border-radius: 50%; background-color: ' + color + '; margin-right: 8px;\"></div>' + data + '</div>';
        }")
        )
          ),
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel')
        ),
        rownames = FALSE,
        escape = FALSE,
        filter = 'top',
        class = 'cell-border stripe'
      ) |>
        DT::formatStyle(
          columns = 1:7,  # Use 1-based indexing instead of 0:6
          textAlign = 'center',
          vertical = 'middle'
        ) |>
        DT::formatStyle(
          columns = c('sum'),  # Use column names 
          background = DT::styleColorBar(
            c(0, max(data$sum, na.rm = TRUE)),  # Provide proper range for the color bar
            '#3fc1c5'
          ),
          backgroundSize = '98% 88%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        ) |> 
        DT::formatStyle(
          columns = c('supply_good'),  # Use column names 
          background = DT::styleColorBar(
            c(0, max(data$sum, na.rm = TRUE)),  # Provide proper range for the color bar
            '#3CB371'
          ),
          backgroundSize = '98% 88%',
          backgroundRepeat = 'no-repeat',
          backgroundPosition = 'center'
        )
 }, server = TRUE) 
}
