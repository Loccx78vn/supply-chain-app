box::use(
  shiny[NS, callModule, showNotification, tagList, tags,reactive],
  leaflet[labelOptions,leafletOutput, renderLeaflet,leaflet, addProviderTiles, addCircleMarkers, addLegend],
  leaflet.extras[addResetMapButton],
  dplyr[filter],
  magrittr[`%>%`],
  htmltools[div]
)

box::use(
  data/database,
  app/constants,
  app/logic/func_overview[gen_filter_region]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-map-container",
      leafletOutput(ns("map"))
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
  
  output$map <- renderLeaflet({
    
    filtered_data<-data()
    
    labels <- paste0("<strong>Region: </strong>", filtered_data$region, "<br/>",
                     "<strong>Facility: </strong>", filtered_data$facilities, "<br/>") |> 
      lapply(htmltools::HTML)
    
    
    leaflet(filtered_data) |>
      addProviderTiles("CartoDB.Positron") |>
      addCircleMarkers(radius = 10, fillOpacity = 0.7, stroke = FALSE, 
                       label = ~labels, 
                       lng = ~filtered_data$longitude, 
                       lat = ~filtered_data$latitude, 
                       color = ~constants$palPwr(filtered_data$region),
                       labelOptions = constants$font) |> 
      addLegend(position = "bottomright", 
                values = ~region, 
                opacity = .7, 
                pal = constants$palPwr, 
                title = "Region") |> 
      addResetMapButton()
  })
}