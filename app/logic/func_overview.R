box::use(
  shiny[showNotification, req],
  dplyr[filter, select],
  tidyr[pivot_longer],
  magrittr[`%>%`]
)


#' @export
gen_card <- function(input_data) {

  data <- input_data

  if (nrow(data) == 0) {
    showNotification("No data imported to module card.", type = "warning")
    return(NULL)
  }
  
  return(data)
}  

#' @export
gen_filter_region <- function(input_data,filter_region) {
  
  if (filter_region == "All") {
    subset(
      x = input_data
    )
  } else {
    subset(
      x = input_data,
      subset = region == filter_region
    )
  }
}


#' @export
gen_barchart_data <- function(input_data,filter_region) {
  req(input_data)
  
  # If input_data is empty, show a notification and return NULL
  if (nrow(input_data) == 0) {
    showNotification("No data", type = "warning")
    return(NULL)
  }
  
  # Process the input_data
  input_data <- input_data |> 
    select(-total_sales) |> 
    pivot_longer(cols = c(total_income, total_revenue), 
                 names_to = "metric", 
                 values_to = "value")
  
  filtered_data <- gen_filter_region(input_data, filter_region)
  
  if (nrow(filtered_data) == 0) {
    showNotification("No data", type = "warning")
    return(NULL)
  }
  
  return(filtered_data)
}


