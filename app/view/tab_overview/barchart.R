# Use box to import necessary functions and modules
box::use(
  shiny[NS, callModule, showNotification,tagList,tags,reactive],
  highcharter[...],
  dplyr[filter, select],
  tidyr[pivot_longer],
  magrittr[`%>%`],
  htmltools[div],
  ggplot2[element_blank]
)

box::use(
  data/database
)

box::use(
  app/logic/func_overview[gen_barchart_data]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-barchart-container",
      highchartOutput(ns("barchart"))
    )
  )
}

#' @export
init_server <- function(id, df, region) {
  callModule(server, id, df, region)
}

#' @export
server <- function(input, output, session, df, region) {

  # Import the data from the database module
  data <- reactive({
    gen_barchart_data(df,region())
  })
  
  
  output$barchart <- renderHighchart({
    
    filtered_data <- data()
    
    hchart(filtered_data,
           "column", 
           hcaes(y = value, x = region, group = metric)) |> 
      hc_legend(element_blank())
  })
}
