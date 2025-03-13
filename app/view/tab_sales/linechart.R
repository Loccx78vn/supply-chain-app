# Use box to import necessary functions and modules
box::use(
  shiny[NS, callModule, showNotification,tagList,tags,req,reactive],
  highcharter[...],
  dplyr[filter, mutate, case_when],
  tidyr[pivot_longer],
  magrittr[`%>%`],
  htmltools[div],
  stats[quantile],
  ggplot2[element_blank]
)

# Import the data from the database module
box::use(data/database,
         app/constants,
         app/logic/func_sales[gen_daily_data])

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-linechart-container",
      highchartOutput(ns("linechart"))
    )
  )
}

#' @export
init_server <- function(id, df, region, warehouse) {
  callModule(server, id, df, region, warehouse)
}

#' @export
server <- function(input, output, session, df, region, warehouse) {
  
  daily_data <- reactive({
    gen_daily_data(df, region(), warehouse())
  })
  
  filtered_data<-gen_daily_data(database$daily, "AFRICA", "DC001")
  
  output$linechart <- renderHighchart({
    
    filtered_data<-daily_data()
    
    hchart(filtered_data, 
           type = "area", 
           hcaes(x = date, 
                 y = sum, 
                 group = wh_code)) |> 
      hc_legend(element_blank()) |> 
      hc_xAxis(
        title = list(
          text = "Date", 
          style = list(fontWeight = "bold")
        )
      ) |> 
      hc_yAxis(
        title = list(
          text = "The total sales per day", 
          style = list(fontWeight = "bold")
        )
      )
  })
}
