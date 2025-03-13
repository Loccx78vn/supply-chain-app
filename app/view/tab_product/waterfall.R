# Import the required libraries using box::use
box::use(
  shiny[...],
  dplyr[filter],
  plotly[plot_ly, renderPlotly, plotlyOutput, layout],
  htmltools,
  magrittr[`%>%`]
)

# Import the data from the database module
box::use(
  data/database,
  app/logic/func_product[gen_waterfall]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-waterfall-container",
      plotlyOutput(ns("waterfall"))
    )
  )
}


#' @export
init_server <- function(id, df, product, region, store) {
  callModule(server, id, df, product, region, store)
}

#' @export
server <- function(input, output, session, df, product, region, store) {

  data<-reactive({
    gen_waterfall(df, product(), region(), store())
  })
  # Render the waterfall plot
  output$waterfall <- renderPlotly({
    
    waterfall_data <- data()
    
    plot_ly(
      waterfall_data, 
      type = "waterfall", 
      x = ~x, 
      textposition = "outside", 
      text = ~paste("Value:", y, "<br>Percentage:", percent, "%"),
      y = ~y, 
      measure = ~measure,
      connector = list(line = list(color = "rgb(63, 63, 63)"))) %>% 
      layout(xaxis = list(title = ""),
             yaxis = list(title = ""),
             autosize = TRUE,
             showlegend = TRUE)
  })
}