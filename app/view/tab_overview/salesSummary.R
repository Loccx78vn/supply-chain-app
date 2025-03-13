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
        uiOutput(ns("sales_summary"))
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
  
  output$sales_summary<-renderUI({
    
    card <- data()
    
    value_box(
      title = "Total revenue",
      value = scales::unit_format(unit = "$")(card[["revenue"]]),
      showcase = bsicons::bs_icon("cash-coin"),
      theme = value_box_theme(bg = "#05c208", fg = "#ffffff")
    )
  })
}