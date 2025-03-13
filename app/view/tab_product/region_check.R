box::use(
  shiny[...]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  # Warning message UI as a box
  uiOutput(ns("warning_region"))
}

#' @export
init_server <- function(id, region = NULL) {
  moduleServer(id, function(input, output, session) {
    
    # Render warning message if region or store is not properly selected
    output$warning_region <- renderUI({
      req(region())
      
      if (region() == "Choose a region" ||  region() == "No region available") {
        
        warning_content <- tags$div(
          if (region() == "Choose a region") {
            tags$p(tags$strong(style = "color: red;", "Missing Selection:"), "Please select a valid region from the dropdown menu.")
          },
          if (region() == "No region available") {
            tags$p(tags$strong(style = "color: red;", "Missing Selection:"), "No data imported to filters")
          }
        )
        
        # Return a styled warning box
        div(
          class = "alert alert-warning",
          style = "margin-top: 10px;",
          tags$div(
            warning_content
          )
        )
      } else {
        # Return NULL if no warning needed
        NULL
      }
    })
  })
}