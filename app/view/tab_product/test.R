box::use( 
  shiny[...] 
)

#' @export 
ui <- function(id) { ns <- NS(id)
  tagList( # Add CSS for positioning and styling tags$style(HTML(" .info-icon-container { position: relative; display: inline-block; z-index: 10000; /* Extremely high z-index to overcome any other elements / } .info-icon { cursor: pointer; background-color: white; color: #2c3e50; font-size: 12px; padding: 5px; border-radius: 50%; border: 2px solid #2c3e50; / Darker border / box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); / Subtle shadow / transition: all 0.3s ease; position: relative; z-index: 10001; / Even higher z-index for the icon / } .info-icon:hover { background-color: #4285F4; / Change background color on hover / color: white; / Change text color to white on hover / transform: scale(1.1); / Slight zoom effect / } .info-panel { display: none; position: absolute; left: 300px; top: 120px; width: 300px; background: linear-gradient(145deg, #ffffff, #f1f1f1); / Soft gradient / border: 1px solid #2c3e50; border-radius: 12px; / Smooth corners / padding: 20px; box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1); / Deep shadow / z-index: 10002; / Ultra high z-index / color: #2c3e50; / Text color / font-size: 16px; max-height: 80vh; / Limit height to 80% of viewport height / overflow-y: auto; / Add scroll if content is too large / } .notification-title { font-weight: bold; font-size: 18px; color: #2c3e50; margin-bottom: 15px; display: flex; align-items: center; } .info-panel ul { margin-left: 20px; } .info-panel p, .info-panel li { margin-bottom: 10px; } .info-panel .diamond-icon { font-size: 30px; color: #f39c12; / Gold color for diamond */ margin-right: 10px; }
  
  /* Fix for your layout */
    .card-header {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
  
  /* Make sure the info container doesn't disrupt layout */
    .card-header .info-icon-container {
        margin-left: 5px;
    }
")),

# Container for info icon and panel
div(
  class = "info-icon-container",
  # Info icon
  div(
    class = "info-icon",
    id = ns("info_icon"),
    icon("info-circle"),
    onclick = sprintf("toggleInfoPanel('%s')", ns("info_panel"))
  ),
  
  # Info panel
  div(
    id = ns("info_panel"),
    class = "info-panel",
    div(
      class = "notification-title",
      div(class = "diamond-icon", HTML("&#11088;")),  # Diamond icon
      span("About This Section")
    ),
    p("This section displays visualizations related to product components and costs."),
    p("To use this section effectively:"),
    tags$ul(
      tags$li("First, select a product from the dropdown menu"),
      tags$li("Then select a region"),
      tags$li("Finally, select a store")
    ),
    p("All three selections are required for the visualizations to display properly.")
  )
),

# JavaScript for toggling the info panel
tags$script(HTML("
  // Function to toggle info panel
  function toggleInfoPanel(panelId) {
    var panel = document.getElementById(panelId);
    if (panel.style.display === 'block') {
      panel.style.display = 'none';
    } else {
      // Hide any other open panels first
      var allPanels = document.getElementsByClassName('info-panel');
      for (var i = 0; i < allPanels.length; i++) {
        allPanels[i].style.display = 'none';
      }
      
      // Show this panel
      panel.style.display = 'block';
      
      // Make sure the panel stays within viewport
      setTimeout(function() {
        var panelRect = panel.getBoundingClientRect();
        var viewportHeight = window.innerHeight;
        var viewportWidth = window.innerWidth;
        
        // Adjust vertical position if needed
        if (panelRect.bottom > viewportHeight) {
          var newTop = Math.max(0, (viewportHeight - panelRect.height) / 2);
          panel.style.top = newTop + 'px';
        }
        
        // Adjust horizontal position if panel goes off screen to the left
        if (panelRect.left < 0) {
          panel.style.left = '0';
          panel.style.right = 'auto';
        }
      }, 50);
    }
  }
  
  // Close panel when clicking outside
  document.addEventListener('click', function(event) {
    if (!event.target.closest('.info-icon-container')) {
      var panels = document.getElementsByClassName('info-panel');
      for (var i = 0; i < panels.length; i++) {
        panels[i].style.display = 'none';
      }
    }
  });
  
  // Make sure our panel is on top of any other elements
  document.addEventListener('DOMContentLoaded', function() {
    var panels = document.getElementsByClassName('info-panel');
    for (var i = 0; i < panels.length; i++) {
      document.body.appendChild(panels[i]);
    }
  });
"))