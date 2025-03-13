box::use(
  shiny[NS, callModule, showNotification,tags,tagList,reactive],  
  plotly[renderPlotly,plotlyOutput,plot_ly, layout],                                
  dplyr[filter, select, distinct],                        
  glue[glue],
  htmltools[div],
  magrittr[`%>%`]
)

# Import the data from the database module
box::use(data/database,
         app/logic/func_product[gen_sankey])

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-sankey-container",
      plotlyOutput(ns("sankey"))
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
    gen_sankey(df, product(), region(), store())
  })
  
  
  output$sankey <- renderPlotly({
    
    filtered_data<-data()
    
    fig <- plot_ly(
      type = "sankey",
      orientation = "h",
      valueformat = ".0f",
      valuesuffix = "TWh",
      node = list(
        pad = 15,  
        thickness = 30,  
        line = list(color = "black", width = 0.5),  
        label = filtered_data$nodes$name,  
        color = filtered_data$nodes$color  
      ),
      link = list(
        source = filtered_data$links$source,  
        target = filtered_data$links$target,  
        value = filtered_data$links$value  
      )
    )
    
    fig <- fig |> 
      layout(
        title = "Sankey Diagram of Product Flow",
        font = list(size = 12),
        xaxis = list(showgrid = FALSE, zeroline = FALSE),
        yaxis = list(showgrid = FALSE, zeroline = FALSE)
      ) 
    
    fig
  })
}
