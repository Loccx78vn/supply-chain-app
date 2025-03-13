box::use(app/constants)

box::use(
  dplyr[...],    # for data manipulation
  tidyr[pivot_longer],                                            # for reshaping data
  stringr[str_sub],                                               # for string manipulation
  lubridate[month],                                               # for date manipulations
  stats[quantile],                                                # for statistical operations
  leaflet[makeIcon],
  magrittr[`%>%`],
  stats[runif]
)


## Enterprise data-----------------------------------------------
regions <- c("ASIA", "AFRICA", "EUROPE", "NORTHAMERICA", "SOUTHAMERICA")
num_entries <- 30  # Number of entries to generate

generate_code <- function(prefix, num) {
  sprintf("%s-%03d", prefix, num)
}

enterprise_data <- data.frame(
  region = sample(regions, num_entries, replace = TRUE),
  mf_code = sapply(ceiling(sample(1:20, num_entries, replace = TRUE)), function(x) generate_code("MF", x)),
  wh_code = sapply(ceiling(sample(1:20, num_entries, replace = TRUE)), function(x) generate_code("WH", x)),
  dc_code = sapply(ceiling(sample(1:20, num_entries, replace = TRUE)), function(x) generate_code("DC", x)),
  product_code = sapply(ceiling(sample(1:20, num_entries, replace = TRUE)), function(x) generate_code("PRO", x))
)

enterprise_data$SKU <- paste0(
  substr(enterprise_data$region, 1, 3), 
  "-", gsub("-", "", enterprise_data$mf_code),
  "-", gsub("-", "", enterprise_data$dc_code),
  "-", gsub("-", "", enterprise_data$wh_code),
  "-", gsub("-", "", enterprise_data$product_code)
)

## Locations data-----------------------------------------------

region_bounds <- data.frame(
  region = c("ASIA", "AFRICA", "EUROPE", "NORTHAMERICA", "SOUTHAMERICA"),
  lat_min = c(1, -35, 35, 24, -56),
  lat_max = c(81, 37, 72, 50, 12),
  long_min = c(60, -25, -30, -170, -75),
  long_max = c(180, 60, 50, -50, -35)
)

generate_coordinates <- function(region) {
  bounds <- region_bounds %>% filter(region == !!region)
  latitude <- runif(1, bounds$lat_min, bounds$lat_max)
  longitude <- runif(1, bounds$long_min, bounds$long_max)
  return(c(latitude, longitude))
}

location_data <- enterprise_data %>%
  pivot_longer(
    cols = c(mf_code, wh_code, dc_code),
    names_to = "facility_type",
    values_to = "facilities"
  ) %>%
  select(region, facilities)

coordinates <- t(sapply(location_data$region, generate_coordinates))
colnames(coordinates) <- c("latitude", "longitude")

location_data<- as.data.frame(cbind(location_data,coordinates))

## Sale data-------------------------------------------------
num_days <- 90
start_date <- Sys.Date() - num_days
date_seq <- seq.Date(from = start_date, by = "day", length.out = num_days)

sales_data <- data.frame()

for (SKU in unique(enterprise_data$SKU)) {
  
  daily_sales <- sample(1:100, num_days, replace = TRUE)
  selling_price <- round(runif(num_days, 10, 100), 2)
  net_income <- selling_price*daily_sales*20/100
  
  temp_data <- data.frame(
    date = date_seq,
    SKU = SKU,
    daily_sales = daily_sales,
    selling_price = selling_price,
    net_income = net_income
  )
  
  sales_data <- rbind(sales_data, temp_data)
}

## Procurement data-----------------------------------------------
set.seed(123)

suppliers <- constants$suppliers

generate_random_product <- function() {
  product_names <- c("Grocery Item", "Beverage", "Dairy Product", "Snack", "Frozen Food", "Household Item", "Cosmetic", "Health Supplement", "Electronics", "Stationery")
  features <- c("Organic", "Gluten-Free", "Low Sugar", "High Protein", "Non-GMO", "Vegan", "Locally Sourced", "Eco-Friendly", "Premium Quality", "Imported")
  
  product_name <- sample(product_names, 1)
  feature <- sample(features, 1)
  
  return(list(product_name = product_name, feature = feature))
}

procurement_data <- data.frame()

for (SKU in unique(enterprise_data$SKU)) {
  supplier <- sample(suppliers, 1)
  random_product <- generate_random_product()
  
  expiry_date <- Sys.Date() + sample(30:180, 1)
  
  temp_data <- data.frame(
    SKU = SKU,
    supplier = supplier,
    product_name = random_product$product_name,
    feature = random_product$feature,
    expiry_date = expiry_date
  )
  
  procurement_data <- rbind(procurement_data, temp_data)
}

## Historical data-----------------------------------------------
historical_data <- data.frame(
  region = rep(c("EUROPE", "AFRICA", "SOUTHAMERICA", "NORTHAMERICA", "ASIA"), each = 6),
  month = rep(as.Date(paste(2024, 1:6, 1, sep = "-")), times = 5),
  total_sales = sample(800:15000, 30, replace = TRUE)
) 

convert_region <- function(abbrev) {
  full_names <- c("AFR" = "AFRICA", "ASI" = "ASIA", "EUR" = "EUROPE", 
                  "NOR" = "NORTHAMERICA", "SOU" = "SOUTHAMERICA", "All" = "All Regions")
  return(full_names[abbrev])
}

## summary sales data-----------------------------------------------
summary_sales <- sales_data |> 
  mutate(region = substr(SKU, 1, 3)) |> 
  group_by(region, month = month(date)) |> 
  summarise(total_sales = sum(daily_sales),
            total_income = sum(net_income),
            total_revenue = sum(selling_price*daily_sales)) |> 
  mutate(month = as.Date(paste(2024, month, 1, sep = "-")),
         region = convert_region(region))

## Data for cards-----------------------------------------------
card <- sales_data |> 
  summarise(
    revenue = sum(selling_price, na.rm = TRUE),
    total_sales = ceiling(sum(daily_sales, na.rm = TRUE)),
    net_income = sum(net_income, na.rm = TRUE)
  )

## Map data-----------------------------------------------
map<- sales_data |>
  left_join(enterprise_data, by = "SKU") |>
  group_by(region,
           wh_code,
           month = month(date)) |>
  summarise(total_sales = sum(daily_sales)) |> 
  ungroup() |> 
  left_join(location_data,
            by = c("region", 
                   "wh_code" = "facilities")) |>
  select(c(longitude,
           latitude,
           total_sales,
           month,
           region,
           wh_code))

## Sales daily data-----------------------------------------------
daily <- sales_data |> 
  mutate(wh_code = substr(SKU,11,15),
         region = substr(SKU,1,3)) |> 
  group_by(region,wh_code,date) |> 
  summarise(sum = sum(daily_sales)) |> 
  ungroup() 


region <- constants$region

city_lookup <- constants$city_lookup

flag_url = constants$flag_url

daily$region <- region[daily$region]

quantiles <- quantile(daily$sum, probs = c(0.5, 0.7, 0.9))

## Component cost-----------------------------------------------
set.seed(123)
product_types <- constants$product_types

brands <- constants$brands

component_cost<-procurement_data |> 
  select(SKU) |> 
  mutate(
    product_name = paste(sample(product_types, 
                                size = 30, 
                                replace = TRUE), 
                         sample(brands, 
                                size = 30, 
                                replace = TRUE)),
    material = runif(30, min = 10, max = 100),
    production = runif(30, min = 20, max = 150),
    transportation = runif(30, min = 5, max = 50),
    store = runif(30, min = 15, max = 70),
    net_income = runif(30, min = 10, max = 40),
    revenue = rep(0,30),
    region = substr(SKU,1,3),
    dc_code = substr(SKU,11,15)) |> 
  pivot_longer(cols = c(material, 
                        production,
                        transportation,
                        store, 
                        net_income,
                        revenue), 
               names_to = "component", 
               values_to = "cost")