# Import necessary packages
box::use(
  shiny[req, showNotification],
  dplyr[filter, select, mutate, recode, rename, distinct, left_join],
  magrittr[`%>%`],
  sf[st_as_sf]
)

#' @export
gen_filter_product_region_store <- function(input_data, filter_product, filter_region, filter_store) {
  
  req(input_data)
  
  # Check if the dataset is empty
  if (nrow(input_data) == 0) {
    showNotification("No data available", type = "warning")
    return(NULL)
  }
  
  # Check if the necessary columns exist in input_data
  required_columns <- c("product_name", "region", "dc_code")
  missing_columns <- setdiff(required_columns, colnames(input_data))
  
  if (length(missing_columns) > 0) {
    showNotification(paste("Missing columns:", paste(missing_columns, collapse = ", ")), type = "warning")
    return(NULL)
  }
  
  # Check if filter_product, filter_region or filter_store are missing
  if (is.null(filter_product) || filter_product == "") {
    showNotification("Product filter is missing", type = "warning")
    return(NULL)
  }
  
  if (is.null(filter_region) || filter_region == "") {
    showNotification("Region filter is missing", type = "warning")
    return(NULL)
  }
  
  if (is.null(filter_store) || filter_store == "") {
    showNotification("Store filter is missing", type = "warning")
    return(NULL)
  }
  
  # Filter the data based on the criteria
  filtered_data <- filter(input_data, product_name == filter_product &
                            region == filter_region & 
                            dc_code == filter_store)
  
  # Check if the filtered data is empty
  if (nrow(filtered_data) == 0) {
    showNotification("No data matches the selected filters", type = "warning")
    return(NULL)
  }
  
  return(filtered_data)
}


#' @export
gen_waterfall <- function(input_data, filter_product, filter_region, filter_store) {
  
  req(input_data)
  
  # If input_data is empty, show a notification and return NULL
  if (nrow(input_data) == 0) {
    showNotification("No data", type = "warning")
    return(NULL)
  }
  
  filtered_data <- gen_filter_product_region_store(input_data, filter_product, filter_region, filter_store)
  
  filtered_data$measure = c("relative", "relative", "relative","relative", "relative", "total")
  
  df <- data.frame(x = factor(filtered_data$component, 
                              levels = filtered_data$component), 
                   y = round(filtered_data$cost, 2),
                   percent = round(filtered_data$cost / sum(filtered_data$cost) * 100, 2),  
                   measure = filtered_data$measure)
  return(df)
}


#' @export
gen_chain_map <- function(location, component_cost, filter_product) {
  
  req(location)
  req(component_cost)
  
  if (nrow(location) == 0) {
    showNotification("No data from location data", type = "warning")
    return(NULL)
  }
  
  if (nrow(component_cost) == 0) {
    showNotification("No data from component_cost data", type = "warning")
    return(NULL)
  }
  
  # Process location data
  location_data <- location |> 
    mutate(region = recode(region, 
                           AFRICA = "AFR",
                           ASIA = "ASI",
                           EUROPE = "EUR",
                           NORTHAMERICA = "NOR",
                           SOUTHAMERICA = "SOU"),
           facilities = gsub("-", "", facilities))
  
  # Process component cost data
  cost_data <- component_cost |> 
    select(c(SKU, product_name, region)) |> 
    mutate(
      wh_facility = substr(SKU, 17, 21),  
      mf_facility = substr(SKU, 5, 9),    
      dc_facility = substr(SKU, 11, 15)
    ) |> 
    distinct()
  
  # Merge data with location data for various facilities
  data <- cost_data |> 
    left_join(location_data |> 
                rename(wh_facility = facilities, 
                       long = longitude, 
                       lat = latitude), 
              by = c("wh_facility", "region"), 
              relationship = "many-to-many") |> 
    left_join(location_data |> 
                rename(mf_facility = facilities, 
                       long = longitude, 
                       lat = latitude), 
              by = c("mf_facility", "region"), 
              relationship = "many-to-many") |> 
    left_join(location_data |> 
                rename(dc_facility = facilities, 
                       long = longitude, lat = latitude), 
              by = c("dc_facility", "region"), 
              relationship = "many-to-many")
  
  # Convert to spatial objects
  data <- data |> 
    mutate(
      wh = st_as_sf(data.frame(long = long.x, lat = lat.x), coords = c("long", "lat"), crs = 4326),
      mf = st_as_sf(data.frame(long = long.y, lat = lat.y), coords = c("long", "lat"), crs = 4326),
      dc = st_as_sf(data.frame(long = long, lat = lat), coords = c("long", "lat"), crs = 4326)
    ) |> 
    select(-c(long.x, lat.x, long.y, lat.y, long, lat)) 
  
  # Filter data based on the given product name
  filtered_data <- data |> 
    filter(product_name == filter_product)
  
  
  if (nrow(filtered_data) == 0) {
    showNotification("Filters dont work", type = "warning")
    return(NULL)
  }
  
  return(filtered_data)
}


#' @export
gen_sankey <- function(input_data,filter_product,filter_region,filter_store) {
  
  req(input_data)
  
  # If input_data is empty, show a notification and return NULL
  if (nrow(input_data) == 0) {
    showNotification("No data", type = "warning")
    return(NULL)
  }
  
  
  data <- gen_filter_product_region_store(input_data, filter_product, filter_region, filter_store)
  
  # Extract paths from the SKU column
  paths <- substr(data$SKU, 5, 28)
  
  # Create nodes data frame with unique names from product_name and SKU paths
  nodes <- data.frame(name = c(unique(data$product_name),
                               unique(unlist(strsplit(substr(data$SKU, 5, 28), "-")))
  )
  )
  
  # Add types and colors to nodes
  nodes$type <- ifelse(grepl("^MF", nodes$name), "Manufacturer",
                       ifelse(grepl("^WH", nodes$name), "Warehouse",
                              ifelse(grepl("^DC", nodes$name), "Distribution Center", 
                                     ifelse(grepl("^PRO", nodes$name), "Store",
                                            "Product")
                              )
                       )
  )
  
  nodes$color <- ifelse(nodes$type == "Product", "#fce103",
                        ifelse(nodes$type == "Manufacturer", "#1f77b4",    # Blue
                               ifelse(nodes$type == "Warehouse", "#ff7f0e",  # Orange
                                      ifelse(nodes$type == "Distribution Center", "#2ca02c",  # Green
                                             "#d62728")
                               )
                        )
  )
  
  # Initialize links dataframe
  links <- data.frame(source = integer(), target = integer(), value = integer())
  
  # Loop through paths and create links
  for (path in paths) {
    codes <- strsplit(path, "-")[[1]]
    
    source_index <- 0  
    target_index <- match(codes[1], nodes$name) - 1
    links <- rbind(links, data.frame(source = source_index, 
                                     target = target_index, 
                                     value = 1))
    
    for (i in seq_along(codes)[-length(codes)]) {
      source_index <- match(codes[i], nodes$name) - 1
      target_index <- match(codes[i + 1], nodes$name) - 1
      links <- rbind(links, data.frame(source = source_index, 
                                       target = target_index, 
                                       value = 1))
    }
  }
  
  # Return the result as a list with nodes and links
  result <- list(nodes = nodes, links = links)
  
  return(result)
}