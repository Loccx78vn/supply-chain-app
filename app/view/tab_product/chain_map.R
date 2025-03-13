# Import the required libraries using box::use
box::use(
  shiny[NS, tagList, callModule, showNotification,tags,reactive],
  dplyr[mutate, select, rename, filter, distinct],
  leaflet[leaflet, addTiles, addMarkers, addPolylines,leafletOutput,renderLeaflet],
  leaflet.extras[addResetMapButton],
  sf[st_as_sf, st_coordinates],
  htmltools[HTML,div],
  magrittr[`%>%`]
)

# Import the data from the database module
box::use(data/database,
         app/constants,
         app/logic/func_product[gen_chain_map])

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
      class = "chart-chain_map-container",
      leafletOutput(ns("chain_map"))
    )
  )
}

#' @export
init_server <- function(id, location, component_cost, product) {
  callModule(server, id, location, component_cost, product)
}

#' @export
server <- function(input, output, session, location, component_cost, product) {
  
  chain <- reactive({
    gen_chain_map(location, component_cost, product())
  })
  
  output$chain_map <- renderLeaflet({
    
    data <- chain()
    
    leaflet(data) |>
      addTiles() |>
      addMarkers(data = data$wh, 
                 ~st_coordinates(data$wh)[,1], ~st_coordinates(data$wh)[,2], 
                 label = ~paste0("<strong> ID Warehouse: </strong> ", data$wh_facility) |> lapply(htmltools::HTML),
                 icon = constants$warehouse_icon) |>
      addMarkers(data = data$mf, ~st_coordinates(data$mf)[,1], ~st_coordinates(data$mf)[,2], 
                 label = ~paste0("<strong> ID Manufacter: </strong> ", data$mf_facility)|> lapply(htmltools::HTML),
                 icon = constants$mf_icon) |>
      addMarkers(data = data$dc, ~st_coordinates(data$dc)[,1], ~st_coordinates(data$dc)[,2], 
                 label = ~paste0("<strong> ID Distribution Center: </strong> ", data$dc_facility)|> lapply(htmltools::HTML),
                 icon = constants$dc_icon) |> 
      
      addPolylines(
        lng = c(st_coordinates(data$wh)[,1], st_coordinates(data$mf)[,1], st_coordinates(data$dc)[,1]),
        lat = c(st_coordinates(data$wh)[,2], st_coordinates(data$mf)[,2], st_coordinates(data$dc)[,2]),
        color = "blue", weight = 2, opacity = 0.7, dashArray = "5,5", 
        popup = "Supply Chain Path"
      ) |> 
      addResetMapButton()
  }) 
}

