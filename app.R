
library(httr)
library(jsonlite)
library(leaflet)
library(leaflet.extras)
library(htmltools)
library(mapboxapi)
library(shiny)
library(shinyWidgets)
library(shinydashboard)

ClinicCoordinates.df.final <- readRDS("ClinicAddresses.rds")

data <- ClinicCoordinates.df.final

# Define Shiny App UI
header1 <- dashboardHeader(title = "VaxMap")

sidebar1 <-
    dashboardSidebar(sidebarMenu(
        menuItem(
            searchInput(
                inputId = "city",
                label = "City",
                value = "Toronto",
                placeholder = NULL
            )
        )
    ))

body1 <- dashboardBody(fluidPage(
    
    title = "Map",
    width = "100%",
    solidHeader = TRUE,
    status = "primary",
    leafletOutput("baseMap"),
    tags$style(type = "text/css", "#baseMap {height: calc(100vh - 80px) !important;}"),
    tags$head(tags$script(src = "http://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js")),
    tags$head(tags$style("#carrier {color: red; font-size: 20px;font-style: italic;}")),
)
)

ui <- dashboardPage(header1, sidebar1, body1)

# Define SERVER logic
server <- function(input, output, session) {
    
    filteredData <- reactive({
        data[data$city %in% input$city[1],]
    })
    
    output$baseMap <- renderLeaflet({
        leaflet() %>%
            setView(-80,44,zoom=8) %>% 
            enableTileCaching() %>% 
            addProviderTiles(providers$CartoDB.DarkMatter, group = "Dark",tileOptions(useCache=TRUE, crossOrigin=T)) %>%
            addProviderTiles(providers$Esri.WorldImagery, group = "Satellite",tileOptions(useCache=TRUE, crossOrigin=T)) %>%
            addProviderTiles(providers$CartoDB.Positron, group = "CartoDB",tileOptions(useCache=TRUE, crossOrigin=T)) %>%
            addProviderTiles(providers$OpenStreetMap, group = "OSM",tileOptions(useCache=TRUE, crossOrigin=T)) %>%
            addFullscreenControl(pseudoFullscreen = F) %>%
            addLayersControl(baseGroups = c("CartoDB", "OSM", "Satellite", "Dark"))
    })
    
    observe({
        
        icon.fa <- makeAwesomeIcon(icon = "hospital", 
                                   markerColor = "pink", 
                                   library = "fa",
                                   iconColor = "white")
        # color_scheme <- viridis::cividis(n_distinct(data$LICENSEE %in% c("Bell Mobility Inc.", "Bell Canada")))
        # pal = colorFactor(color_scheme, data$LICENSEE)
        leafletProxy("baseMap",data = filteredData()) %>%
            clearMarkers() %>% 
            clearMarkerClusters() %>% 
            addAwesomeMarkers(
                lng = ~X1,
                lat = ~X2,
                icon = icon.fa,
                clusterOptions = markerClusterOptions(),
                # minOpacity = .25, 
                # max = 1,
                # radius = 3, 
                # blur = 15, 
                # gradient = viridis::magma(5), 
                # cellSize = 2) %>% 
                popup = htmlEscape(filteredData()[,"full_address"]))%>% 
            fitBounds(
                ~ min(as.numeric(X1)),
                ~ min(as.numeric(X2)),
                ~ max(as.numeric(X1)),
                ~ max(as.numeric(X2))
            )
        
    })
    
} #server


# Run app
shinyApp(ui, server)

