box::use(
  dplyr[filter, mutate, case_when, select],
  shiny[showNotification, req, span],
  glue[glue],
  htmltools[div],
  stats[quantile]
)

box::use(data/database,
         app/constants)

#' @export
status_PI.Index <- function(color = "#aaa", 
                            width = "0.55rem", 
                            height = width)
  span(style = list(
    display = "inline-block",
    marginRight = "0.5rem",
    width = width,
    height = height,
    backgroundColor = color,
    borderRadius = "50%"
  ))

#' @export
gen_filter_region_warehouse <- function(input_data, filter_region, filter_warehouse) {
  
  req(input_data)
  
  # Check if the dataset is empty
  if (nrow(input_data) == 0) {
    showNotification("No data available", type = "warning")
    return(NULL)
  }
  
  # Check if filter_region or filter_warehouse are missing
  if (is.null(filter_region) || filter_region == "") {
    showNotification("Region filter is missing", type = "warning")
    return(NULL)
  }
  
  if (is.null(filter_warehouse) || filter_warehouse == "") {
    showNotification("Warehouse filter is missing", type = "warning")
    return(NULL)
  }
  
  # Filter the data based on the criteria
  filtered_data <- if (filter_warehouse == "All") {
    input_data |> dplyr::filter(region == filter_region)
  } else {
    input_data |> dplyr::filter(region == filter_region & wh_code == filter_warehouse)
  }
  
  # Check if the filtered data is empty
  if (nrow(filtered_data) == 0) {
    showNotification("No data matches the selected filters", type = "warning")
    return(NULL)
  }
  
  return(filtered_data)
}


#' @export
gen_daily_data <- function(input_data,filter_region,filter_warehouse) {
  
  req(input_data)
  
  quantiles <- quantile(database$daily$sum, probs = c(0.5, 0.7, 0.9))
   
  data <- input_data |> 
    mutate(sum = round(sum, 0),
           supply_good = case_when(
             (weekdays(date) %in% c("Thursday", "Saturday")) & (region %in% c("AFRICA", "ASIA")) ~ 500,
             (weekdays(date) %in% c("Thursday", "Saturday")) & (region %in% c("NORTHAMERICA", "SOUTHAMERICA")) ~ 600,
             (weekdays(date) %in% c("Thursday", "Saturday")) & (region == "EUROPE") ~ 400,
             TRUE ~ 0
           )) |> 
    mutate(status = case_when(
      sum >= quantiles[3] ~ "Good",       
      sum >= quantiles[2] ~ "Pass KPI",   
      sum >= quantiles[1] ~ "Okay",       
      TRUE ~ "Bad"             
    ),
    city = constants$city_lookup[database$daily$region],
    flag_url = constants$flag_url[match(region, names(constants$city_lookup))])
  
  if (nrow(data) == 0) {
    showNotification("Daily data object has no data", type = "warning")
    return(NULL)
  }
  
  filtered_data<-gen_filter_region_warehouse(data,filter_region,filter_warehouse)
  
  return(filtered_data)
}

