box::use(
  shiny[NS, callModule, showNotification,tagList,tags,reactive],
  highcharter[...],
  dplyr[filter],
  htmltools[div],
  ggplot2[element_blank]
)

box::use(data/database)

box::use(
  app/logic/func_overview[gen_filter_region]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "card-body",
      highchartOutput(ns("line"))
    )
  )
}

#' @export
init_server <- function(id, df, region) {
  callModule(server, id, df, region)
}


#' @export
server <- function(input, output, session, df, region) {
  
  data<-reactive({
    gen_filter_region(df,region())
  })
  
  output$line <- renderHighchart({
    
    filtered_data<-data()
    
    hchart(filtered_data, 
           "line", 
           hcaes(x = month, 
                 y = total_sales, 
                 group = region)) |> 
      hc_legend(element_blank())
  })
  
}