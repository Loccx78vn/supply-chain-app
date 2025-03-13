# Import the necessary modules with box::use
box::use(
  shiny[...],
  ggplot2[...],
  dplyr[mutate, filter],
  glue[glue],
  thematic[okabe_ito],
  magrittr[`%>%`],
  htmltools[div],
  ggdist[geom_dots, stat_slab],
  ggtext[element_markdown]
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
      class = "chart-boxplot-container",
      plotOutput(ns("boxplot"))
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
    result <- gen_daily_data(df, region(), warehouse())
  })
  
  output$boxplot <- renderPlot({
    
    filtered_data <- daily_data()
    
    region_val <- region()
    wh_code <- warehouse()
    
    if (wh_code == "All") {
      title_text <- glue("Distribution chart of daily demand in <span style='color:{constants$colors[region_val]}'>**{region_val}**</span>")
    } else {
      title_text <- glue("Distribution chart of daily demand for <span style='color:{constants$colors[region_val]}'>**{region_val}**</span> at warehouse <span style='color:{constants$colors[region_val]}'>**{wh_code}**</span>")
    }
    
    ggplot(filtered_data,
           aes(x = sum, 
               fill = region, 
               y = region)) +
      geom_boxplot(width = 0.1) +
      geom_dots(
        side = 'bottom', 
        height = 0.55,
        position = position_nudge(y = -0.075)
      ) +
      stat_slab(
        position = position_nudge(y = 0.075), 
        height = 0.75
      ) +
      scale_fill_manual(values = constants$colors) +
      labs(
        x = element_blank(), 
        y = element_blank(), 
        title = title_text
      ) +
      theme(
        plot.title = ggtext::element_markdown(face = "italic", size = 16, color = "black"),  # White theme title color
        plot.background = element_rect(fill = "white", color = NA),  # White background
        panel.background = element_rect(fill = "white", color = NA),  # White panel background
        axis.text = element_text(color = "black"),  # Black axis text
        axis.title = element_text(color = "black"),  # Black axis titles
        plot.margin = margin(10, 10, 40, 10),  # Space for the notice text at the bottom
        legend.position = 'none'
      )
  })
}