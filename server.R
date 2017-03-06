library(leaflet)
library(maps)
library(rgdal)
library(RColorBrewer)
library(rhdf5)

server <- (function(input, output, session) {
  
  #data for map polygon, area, etc
  states <- readOGR("shp/cb_2015_us_state_20m.shp",
                    layer = "cb_2015_us_state_20m", GDAL1_integer64_policy = TRUE)
  #counties <- readOGR("shp/cb_2015_us_county_20m.shp",
  #                  layer = "cb_2015_us_county_20m", GDAL1_integer64_policy = TRUE)
  
  #ncdc hail event data
  haildf <- h5read("hailevents.h5","events/hail/table")
  
  #function to count number of events in each state
  stateCount <- function(current_state,data) {
    match_events <- data[ which(tolower(data$state) == tolower(current_state)),]
    nevents <- length(match_events[,1])
    return(nevents)
  }
  
  #function to update data based on month slider
  setmonth <- reactive({
    selectdata <-haildf[which(tolower(haildf$month) == tolower(month.name[input$month])),]
    states$HAILEVENTS <- sapply(states$NAME, stateCount, data = selectdata)
    return(states$HAILEVENTS)
  })
  
  #function to get event data from selected month for markers
  getpts <- reactive({
    selectdata <-haildf[which(tolower(haildf$month) == tolower(month.name[input$month])),]
    return(selectdata)
  })
  
  
  #build palette
  ramp <- colorRampPalette(brewer.pal(8,"Oranges"))(8)
  pal <- colorNumeric(ramp, c(0,500), na.color = "#808080",
                      alpha = FALSE, reverse = FALSE)

  #Initial map setup
  map <- leaflet(states) %>% addTiles() %>% setView(-94.85, 38, zoom = 4) %>%
    setMaxBounds(-180, 17, 180 ,59)
  output$myMap <- renderLeaflet(map)
  
  #Observer for month and area normalization
  observe({
     proxy <- leafletProxy("myMap", data = states)
     
     if (input$normvars) {
       hailevents <- setmonth()   
         
       #normalize by square km: ALAND and AWATER are in m^2, so multiply by 1000000
       normfactor <- 1e6/(states$ALAND + states$AWATER)
       hailevents <- 1000*normfactor*hailevents
       cbarvals <- c(0,2)
       
       pal <- colorNumeric(ramp, cbarvals, na.color = "#808080",
                           alpha = FALSE, reverse = FALSE)
       
       proxy %>% clearShapes() %>% clearControls() %>%
         addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                     opacity = 1.0, fillOpacity = 0.8, fillColor = ~pal(hailevents)) %>%
         addLegend("bottomright", pal = pal, values = cbarvals,
                 title = "Hail Reports Per 1000 square km",
                 opacity = 0.8)
     } else {
       hailevents <- setmonth()   
       
       #don't normalize here
       normfactor <- 1
       hailevents <- normfactor*hailevents
       cbarvals <- c(0,500)
       
       pal <- colorNumeric(ramp, cbarvals, na.color = "#808080",
                           alpha = FALSE, reverse = FALSE)
       
       proxy %>% clearShapes() %>% clearControls() %>%
         addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                     opacity = 1.0, fillOpacity = 0.8, fillColor = ~pal(hailevents)) %>%
         addLegend("bottomright", pal = pal, values = c(0,500),
                   title = "Hail Reports",
                   opacity = 0.8)
       
       }
   })

  #Observer for marker addition
  observe({
    eventdata <- getpts()
    df = data.frame(eventdata$lat,eventdata$lon,eventdata$magnitude)
    colnames(df) <- c("lats","lons","mags")
    
    proxy <- leafletProxy("myMap")
    
    if (input$showevents) {
      proxy %>% addMarkers(map,  lng = df$lons, lat = df$lats, 
                           popup = paste(as.character(df$mags)," inches"))
      
    } else {
      proxy %>% clearMarkers()
    }
    
  })
})

