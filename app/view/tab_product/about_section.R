#' @export
box::use(
  shiny[moduleServer, NS, tagList, tags, icon, HTML, div, p, span],
  htmltools,
  fontawesome,
  bslib
)

#' Info Icon UI Function
#' 
#' Creates an information icon with a popup panel
#' 
#' @param id Module ID
#' @param title Title of the info panel
#' @param content Content to display in the info panel (optional)
#' @return A UI element containing the info icon and panel
#' @export
ui <- function(id, title = "About This Section", content = NULL) {
  ns <- NS(id)
  
  tagList(
    tags$style(HTML("
      /* Info Icon and Panel Styles */
      .info-icon-container {
        display: inline-block;
        position: absolute; /* Absolutely position the icon within the parent */
        top: 5px;  /* Adjust top position */
        right: 10px;  /* Adjust right position */
        cursor: pointer;
        z-index: 10000; /* Extreme high z-index to ensure it's above everything */
      }
      
      .info-icon {
        color: #3498db;
        font-size: 18px;
        transition: color 0.3s;
        position: relative; /* Create a stacking context */
        z-index: 10000; /* Match the container */
      }
      
      .info-icon:hover {
        color: #2980b9;
      }
      
      /* Info Panel Style */
      .info-panel {
        display: none;
        position: absolute; /* Position it absolutely inside filter4 */
        width: 300px;
        background-color: white;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        padding: 15px;
        z-index: 10001; /* Even higher than the icon to ensure it's on top */
        top: 30px; /* Position relative to its parent */
        right: 0;
        font-size: 14px;
        line-height: 1.5;
        color: #333;
        border-left: 4px solid #3498db;
      }
      
      .notification-title {
        display: flex;
        align-items: center;
        margin-bottom: 10px;
        font-weight: bold;
        color: #2c3e50;
        font-size: 16px;
      }
      
      .diamond-icon {
        margin-right: 10px;
        color: #f39c12;
      }
      
      /* Active class to show the panel */
      .info-panel.active {
        display: block;
        animation: fadeIn 0.3s;
      }
      
      @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
      }
      
      /* Ensure parent container has size and position context */
      .filter4 {
        position: relative; /* Make sure the container is positioned relatively */
        padding-right: 40px; /* Space for the info icon */
        height: auto; /* Ensure the container has a height */
        width: 100%; /* Adjust width as needed */
      }
    ")),
    # Container for the info icon
    div(
      class = "info-icon-container",
      id = ns("info_container"),
      # Info icon
      div(
        class = "info-icon",
        id = ns("info_icon"),
        icon("circle-info")
      ),
      
      # Info panel - positioned within the container for proper scoping
      div(
        id = ns("info_panel"),
        class = "info-panel",
        div(
          class = "notification-title",
          div(class = "diamond-icon", HTML("&#11088;")),
          span(title)
        ),
        if (!is.null(content)) {
          content
        } else {
          tagList(
            p("This section displays visualizations related to product components and costs."),
            p("To use this section effectively:"),
            tags$ul(
              tags$li("First, select a product from the dropdown menu"),
              tags$li("Then select a region"),
              tags$li("Finally, select a store")
            ),
            p("All three selections are required for the visualizations to display properly.")
          )
        }
      )
    ),
    tags$script(HTML(sprintf("
      $(document).ready(function() {
        const containerId = '%s';
        const panelId = '%s';
        const iconId = '%s';
        
        // Ensure the icon and panel are on top of everything
        $('#' + containerId).css({
          'position': 'relative',
          'z-index': 10000
        });
        
        $('#' + iconId).css({
          'position': 'relative',
          'z-index': 10000
        });
        
        $('#' + panelId).css({
          'z-index': 10001
        });
        
        // Click event for info icon
        $('#' + containerId).on('click', function(e) {
          e.stopPropagation();
          $('#' + panelId).toggleClass('active');
        });
        
        // Close panel when clicking outside
        $(document).on('click', function(e) {
          if (!$(e.target).closest('#' + panelId + ', #' + containerId).length) {
            $('#' + panelId).removeClass('active');
          }
        });
        
        // Prevent panel from closing when clicking inside it
        $('#' + panelId).on('click', function(e) {
          e.stopPropagation();
        });
      });
    ", ns("info_container"), ns("info_panel"), ns("info_icon"))))
  )
}

#' Info Icon Server Function
#' 
#' @param id Module ID
#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # This module doesn't need any server-side logic
    # since all interactivity is handled by JavaScript
  })
}