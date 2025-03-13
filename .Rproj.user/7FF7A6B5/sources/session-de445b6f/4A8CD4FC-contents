# Call packages:
box::use(
  shiny[bootstrapPage, div, moduleServer, NS, tags, observeEvent,
        reactive, selectInput, selectizeInput, updateSelectInput],
  htmltools[htmlTemplate]
)

# Call modules:
box::use(
  app/view/tab_overview/barchart,
  app/view/tab_overview/line,
  app/view/tab_overview/map,
  app/view/tab_overview/salesSummary,
  app/view/tab_overview/productionSummary,
  app/view/tab_overview/usersSummary,
  app/view/tab_sales/boxplot,
  app/view/tab_sales/linechart,
  app/view/tab_sales/table,
  app/view/tab_product/chain_map,
  app/view/tab_product/sankey,
  app/view/tab_product/waterfall,
  app/view/tab_product/about_section,
  app/view/tab_product/region_check,
  app/view/tab_product/store_check
)

# Call function from logic folder
box::use(
  app/logic/get_external_link[get_external_link],
  data/database,
  app/constants
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  # Html template used to render UI
  htmlTemplate(
    "app/static/index.html",
    # Sub-information
    marketplace_website = constants$marketplace_website,
    appTitle = constants$app_title,
    appVersion = constants$app_version,
    selectRegion_ui = selectizeInput(ns("region"), 
                                     "Select Region", 
                                     choices = c("All", sort(unique(database$enterprise_data$region))),
                                     selected = "All",
                                     options = list(
                                       placeholder = "Select a region...",
                                       dropdownParent = "body",
                                       maxOptions = 1000
                                     )),
    
    selectRegionName_ui = selectizeInput(ns("region_name"), 
                                         "Select Region", 
                                         choices = c(sort(unique(database$daily$region))),
                                         selected = "ASIA",
                                         options = list(
                                           placeholder = "Select a region...",
                                           dropdownParent = "body",
                                           maxOptions = 1000
                                         )),
    
    selectWarehouseCode_ui = selectizeInput(ns("wh_code"), 
                                            "Select Warehouse", 
                                            choices = NULL,
                                            options = list(
                                              placeholder = "Select a warehouse...",
                                              dropdownParent = "body",
                                              maxOptions = 1000
                                            )),
    
    selectProductName_ui = selectizeInput(
      inputId = ns("product_name"), 
      label = "Search Product",
      multiple = FALSE,
      choices = c(sort(unique(database$component_cost$product_name))),
      options = list(
        create = FALSE,
        placeholder = "Search Me",
        maxItems = '1',
        dropdownParent = "body",
        maxOptions = 2000,
        onDropdownOpen = I("function($dropdown) {if (!this.lastQuery.length) {this.close(); this.settings.openOnFocus = false;}}"),
        onType = I("function (str) {if (str === \"\") {this.close();}}")
      )
    ),
    
    selectRegionId_ui = selectizeInput(ns("region_id"), 
                                       "Select Region", 
                                       choices = NULL,
                                       options = list(
                                         placeholder = "Select a region ID...",
                                         dropdownParent = "body",
                                         maxOptions = 1000
                                       )),
    
    selectStoreId_ui = selectizeInput(ns("dc_id"), 
                                      "Select Store", 
                                      choices = NULL,
                                      options = list(
                                        placeholder = "Select a store...",
                                        dropdownParent = "body",
                                        maxOptions = 1000
                                      )),
    # Dashboard content
    salesSummary_ui = salesSummary$ui(ns("sales_summary")),
    productionSummary_ui = productionSummary$ui(ns("production_summary")),
    usersSummary_ui = usersSummary$ui(ns("users_summary")),
    map_ui = map$ui(ns("map")),
    line_ui = line$ui(ns("line")),
    barchart_ui = barchart$ui(ns("barchart")),
    table_ui = table$ui(ns("table")),
    linechart_ui = linechart$ui(ns("linechart")),
    boxplot_ui = boxplot$ui(ns("boxplot")),
    chain_map_ui = chain_map$ui(ns("chain_map")),
    sankey_ui = sankey$ui(ns("sankey")),
    waterfall_ui = waterfall$ui(ns("waterfall")),
    info_icon = about_section$ui(ns("show_info")),
    warning_region_ui = region_check$ui(ns("warning_region")),
    warning_store_ui = store_check$ui(ns("warning_store"))
  )
}


#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
   
    ## Update the rest filters--------------------------------------------------------------------
    observeEvent(c(input$region_name), {
      filtered_warehouses <- unique(database$daily$wh_code[database$daily$region == input$region_name])
      
      if (length(filtered_warehouses) > 0) {
        updateSelectInput(session, 
                          "wh_code", 
                          choices = c("All", sort(filtered_warehouses)),
                          selected = "All")  
      } else {
        updateSelectInput(session, 
                          "wh_code", 
                          choices = c("No warehouse available"),
                          selected = NULL)
      }
    })
    
    observeEvent(c(input$product_name), {
      filtered_regions <- unique(database$component_cost$region[database$component_cost$product_name == input$product_name])
      
      if (length(filtered_regions) > 0) {
        updateSelectInput(session, 
                          "region_id", 
                          choices = c("Choose a region", sort(filtered_regions)),
                          selected = "Choose a region")  
      } else {
        updateSelectInput(session, "region_id", 
                          choices = c("No region available"),
                          selected = NULL)
      }
    })
    
    
    observeEvent(c(input$product_name, input$region_id), {
      filtered_stores <- unique(database$component_cost$dc_code[database$component_cost$product_name == input$product_name & 
                                                                  database$component_cost$region == input$region_id])
      
      if (length(filtered_stores) > 0) {
        updateSelectInput(session, 
                          "dc_id", 
                          choices = c("Choose a store", sort(filtered_stores)),
                          selected = "Choose a store") 
      } else {
        updateSelectInput(session, 
                          "dc_id", 
                          choices = c("No store available"),
                          selected = NULL)
      }
    })
    ## Save selected value--------------------------------------------------------------------
    selectRegion <- reactive({
      input$region
    })
    selectRegionName <- reactive({
      input$region_name
    })
    selectWarehouseCode <- reactive({
      input$wh_code
    })
    selectProductName <- reactive({
      input$product_name
    })
    selectRegionId <- reactive({
      input$region_id
    })
    selectStoreId <- reactive({
      input$dc_id
    })
    ## Modules------------------------------------------------------------
    ### Tab Overview-------------------------------------------------------------
    salesSummary$init_server("sales_summary",
                             df = database$card)
    productionSummary$init_server("production_summary",
                                  df = database$card)
    usersSummary$init_server("users_summary",
                             df = database$card)
    barchart$init_server(
      "barchart",
      df = database$summary_sales,
      region = selectRegion)
    line$init_server(
      "line",
      df = database$summary_sales,
      region = selectRegion)
    map$init_server(
      "map",
      df = database$location_data,
      region = selectRegion)
    ## Tab Sales-------------------------------------------------------------
    table$init_server(
      "table",
      df = database$daily,
      region = selectRegionName,
      warehouse = selectWarehouseCode)
    linechart$init_server(
      "linechart",
      df = database$daily,
      region = selectRegionName,
      warehouse = selectWarehouseCode)
    boxplot$init_server(
      "boxplot",
      df = database$daily,
      region = selectRegionName,
      warehouse = selectWarehouseCode)
    ## Tab Product-------------------------------------------------------------
    chain_map$init_server(
      "chain_map",
      location = database$location_data, 
      component_cost = database$component_cost,
      product = selectProductName)
    sankey$init_server(
      "sankey",
      df = database$component_cost,
      product = selectProductName,
      region = selectRegionId,
      store = selectStoreId)
    waterfall$init_server(
      "waterfall",
      df = database$component_cost,
      product = selectProductName,
      region = selectRegionId,
      store = selectStoreId)
    region_check$init_server(
      "warning_region", 
      region = selectRegionId)
    store_check$init_server(
      "warning_store", 
      store = selectStoreId)
  })
}

