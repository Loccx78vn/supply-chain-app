box::use(
  shiny[...],
  bsicons[bs_icon],
  scales[unit_format],
  bslib[value_box,value_box_theme]
)

box::use(data/database,
         app/logic/func_overview[gen_card])

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$div(
        class = "value",
        uiOutput(ns("production_summary"))
    )
  )
}

#' @export
init_server <- function(id, df) {
  callModule(server, id, df)
}

#' @export
server <- function(input, output, session, df) {
  
  data<-reactive({
    gen_card(df)
  })
  
  output$production_summary<-renderUI({
    
    card <- data()
    
    value_box(
      title = "Total sales",
      value = scales::unit_format(unit = "tons", scale = 1)(card[["total_sales"]] * 20 / 1000),
      showcase = bsicons::bs_icon("boxes"),
      theme = value_box_theme(fg = "#6f5d1f", bg = "#cfd8bc")
    )
  })
}