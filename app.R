library(leaflet)
library(leaflet.extras)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(ggmap)
library(geosphere)
library(mapboxapi)
library(htmltools)
library(dplyr)
library(RColorBrewer)
library(viridis)

source("API_KEY.r")

register_google(API_KEY)

data <- readRDS("ClinicAddresses.rds") #loads data
colnames(data)[2:3] <- c("lng", "lat")
data <- data[, c(1, 3, 2, 4:8)]


map_header <- dashboardHeader(title = "VaxMap",
                              titleWidth = 275)

map_sidebar <- dashboardSidebar(
  width = 275,
  sidebarMenu(
    id = 'sidebar1',
    menuItem(
      text = "Search Locations",
      textInput(
        inputId = "userlocation",
        label = "",
        placeholder = "Search Postal"
      ),
      actionButton("go", "Search"),
      numericInput(
        inputId = "distance",
        label = "Radius (km)",
        min = 0,
        max = 500,
        value = 5,
        width = 120,
        step = .5
      )
    )
  ),
  sidebarMenu(
    id = "sidebar2",
    width = "250px",
    menuItem(
      text = "Search Appointments Dates",
      dateInput(
        inputId = "date",
        label = "Earliest Availability",
        width = "250px"
      ),
      selectInput(
        inputId = "age",
        label = "Age",
        choices = c("18+", "30+", "40+", "50+", "55+"),
        width = "250px"
      ),
      selectInput(
        inputId = "requirements",
        label = "Risk Factor",
        choices = c(
          "High-Risk",
          "Medical Conditions",
          "Healthcare Workers",
          "HotSpot",
          "Indigenous Adults",
          "Caregivers"
        )
      )
    )
  )
)

map_body <- dashboardBody(
  fluidPage(
    title = "Map",
    width = "100%",
    solidHeader = TRUE,
    status = "primary",
    leafletOutput("mymap"),
    tags$style(type = "text/css", "#mymap {height: calc(100vh - 80px) !important;}")
  )
)

ui <- dashboardPage(map_header, map_sidebar, map_body)

server3 <- function(input, output, session) {
  distance_clinic_reactive <- eventReactive(input$go, {
    address_latlon <- geocode(input$userlocation)
    dist <- distm(
      x = matrix(data = c(data$lng, data$lat), ncol = 2),
      y = c(lon = address_latlon$lon, lat = address_latlon$lat),
      fun = distVincentySphere
    )
    dist <- dist / 1000
  })
  
  clinic_reactive <-
    reactive({
      data[distance_clinic_reactive() < input$distance,]
    })
  
  output$mymap <- renderLeaflet({
    map <- leaflet() %>%
      addTiles() %>%
      addProviderTiles(providers$CartoDB.Voyager,
                       group = "Voyager",
                       tileOptions(useCache = TRUE, crossOrigin = T)) %>%
      addProviderTiles(
        providers$Esri.WorldImagery,
        group = "Satellite",
        tileOptions(useCache = TRUE, crossOrigin = T)
      ) %>%
      addProviderTiles(providers$CartoDB.Positron,
                       group = "CartoDB",
                       tileOptions(useCache = TRUE, crossOrigin = T)) %>%
      addProviderTiles(providers$OpenStreetMap,
                       group = "OSM",
                       tileOptions(useCache = TRUE, crossOrigin = T)) %>%
      addFullscreenControl(pseudoFullscreen = F) %>%
      addLayersControl(
        baseGroups = c("CartoDB", "OSM", "Satellite", "Voyager"),
        overlayGroups = c("Pins", "Heatmap"),
        options = layersControlOptions(collapsed = FALSE)) %>% 
      hideGroup("Heatmap") %>% 
        setView(
        lng = mean(data$lng),
        lat = mean(data$lat),
        zoom = 9
      )
    map
  })
  
  observe({
    icon.fa <- makeAwesomeIcon(
      icon = "hospital",
      markerColor = "blue",
      library = "fa",
      iconColor = "white"
    )
    
    # pal <- color(
    #   palette = "viridis",
    #   domain = data$city)
    
    content <-
      paste0(
        "<a href='",
        "https://maps.google.com/maps/search/",
        clinic_reactive()$full_address,
        "' target='_blank'>",
        "Google Maps Link</a>",
        "<br>",
        clinic_reactive()$line1
      )
    
    leafletProxy("mymap") %>%
      clearMarkers() %>%
      clearHeatmap() %>%
      # addLayersControl(c("Heatmap","Pins")) %>% 
      addHeatmap(
        data = clinic_reactive(),
        lng = ~ lng,
        lat = ~ lat,
        # gradient = pal(data$city),
        # intensity = ~sqrt(input$distance),
        blur = 35,
        gradient = "magma",
        max = 1,
        radius = 15,
        cellSize = 5,
        group = "Heatmap") %>% 
      addAwesomeMarkers(
        data = clinic_reactive(),
        lng = ~ lng,
        lat = ~ lat,
        icon = icon.fa,
        group = "Pins",
        popup = content
        # popup = paste0("<a href='","https://maps.google.com/maps/search/","vaccine+location/","@",
        # clinic_reactive()$lat,",",clinic_reactive()$lng,",","16z","' target='_blank'>","Google Maps Link</a>")
        # http://maps.google.com/maps/place/<name>/@<lat>,<long>,15z/data=<mode-value>
        # https://maps.google.com?q=@51.03841,-114.01679
        # popup = htmlEscape(apt_reactive()[,"full_address"]
        
      ) %>%
      fitBounds(
        lng1 = min(clinic_reactive()$lng),
        lat1 = min(clinic_reactive()$lat),
        lng2 = max(clinic_reactive()$lng),
        lat2 = max(clinic_reactive()$lat)
      )
  })
}

shinyApp(ui, server3)


## h/t to @iatowks via https://bit.ly/3fnxCon 
