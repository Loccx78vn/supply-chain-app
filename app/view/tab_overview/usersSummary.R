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
        uiOutput(ns("users_summary"))
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
    
    output$users_summary<-renderUI({
      
      card <- data()
      
      value_box(
        title = "Net income",
        value = unit_format(unit = "$")(card[["net_income"]]),
        showcase = bs_icon("wallet"),
        theme = value_box_theme(fg = "#e65100", bg = "#ffcc80"))
  })
}