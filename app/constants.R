box::use(
  leaflet[makeIcon],             
  dplyr[mutate],
  htmltools[HTML],
  leaflet[colorFactor,labelOptions]
)

app_title <- "Enterprise Dashboard"
app_version <- "4.2.2"
marketplace_website <- "Template from https://appsilon.com/"

suppliers <- c("Vinamilk", "Vingroup", "FPT", "Masan Group", "TH True Milk", "Hoa Phat Group", "BIDV", "MobiFone", "Sacombank", "PetroVietnam")

region <- c(
  AFR = "AFRICA",
  ASI = "ASIA",
  EUR = "EUROPE",
  NOR = "NORTHAMERICA",
  SOU = "SOUTHAMERICA"
)

city_lookup <- c(AFRICA = "Nairobi", 
                 ASIA = "Vietnam", 
                 EUROPE = "Rome", 
                 NORTHAMERICA = "Toronto", 
                 SOUTHAMERICA = "Chile")

flag_url = c(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Flag_of_Kenya.svg/1920px-Flag_of_Kenya.svg.png",
  "https://upload.wikimedia.org/wikipedia/commons/2/21/Flag_of_Vietnam.svg",
  "https://upload.wikimedia.org/wikipedia/en/0/03/Flag_of_Italy.svg",
  "https://en.wikipedia.org/wiki/Flag_of_Canada#/media/File:Flag_of_Canada_(Pantone).svg",
  "https://upload.wikimedia.org/wikipedia/commons/7/78/Flag_of_Chile.svg"
)

product_types <- c("Sua chua an",      
                   "Sua tuoi",
                   "Thit heo",
                   "Banh snack",       
                   "Nuoc ngot",
                   "Tra",
                   "Sua bot",
                   "Rau cu qua",
                   "Banh mi",
                   "Sua dau nanh")

brands <- c("Hoa Phat Group", "TH True Milk","Vingroup", "Masan Group")

# Custom icon------------------------------------------------------------------------------
warehouse_icon <- makeIcon(
  iconUrl = "https://raw.githubusercontent.com/Loccx78vn/Genetic-Algorithm/refs/heads/main/warehouse_icon.png", 
  iconWidth = 30, 
  iconHeight = 30
)

dc_icon <- makeIcon(
  iconUrl = "https://raw.githubusercontent.com/Loccx78vn/Genetic-Algorithm/refs/heads/main/distribution_center.png",  
  iconWidth = 30, 
  iconHeight = 30
)

mf_icon <- makeIcon(
  iconUrl = "https://raw.githubusercontent.com/Loccx78vn/Genetic-Algorithm/refs/heads/main/factory.png",  
  iconWidth = 30, 
  iconHeight = 30
)


shiny_logo <- HTML("
  <svg class='logo-svg' viewBox='0 0 100 68'>
    <use href='static/icons/icons-sprite-map.svg#shiny-logo'></use>
  </svg>
")

# Options for map:
palPwr <- colorFactor(palette = c("#1f78b4","#33a02c","#e31a1c","#ff7f00","#6a3d9a"), 
                      domain = c("ASIA", "AFRICA", "EUROPE", "NORTHAMERICA", "SOUTHAMERICA"))


font <- labelOptions(noHide = TRUE, direction = "bottom", 
                     style = list(fontFamily = "serif",
                                  fontStyle = "italic",
                                  boxShadow = "3px 3px rgba(0,0,0,0.25)",
                                  fontSize = "10px",
                                  borderColor = "rgba(0,0,0,0.5)"))

colors <- thematic::okabe_ito(5)
names(colors) <- unique(region)