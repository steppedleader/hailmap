library(leaflet)
library(maps)
library(rgdal)
library(RColorBrewer)

server <- (function(input, output, session) {
  values <- reactiveValues(highlight = c())
  states <- readOGR("shp/cb_2015_us_state_20m.shp",
                    layer = "cb_2015_us_state_20m", GDAL1_integer64_policy = TRUE)
  #counties <- readOGR("shp/cb_2015_us_county_20m.shp",
  #                  layer = "cb_2015_us_county_20m", GDAL1_integer64_policy = TRUE)
  
  
  ramp <- colorRampPalette(brewer.pal(8,"YlOrRd"))(8)
  pal <- colorBin(ramp, states$ALAND, bins = 8, pretty = TRUE, na.color = "#808080",
                  alpha = FALSE, reverse = FALSE)
  
  
  # map <- leaflet(states) %>% setView(-94.85, 38, zoom = 4) %>% 
  #                      setMaxBounds(-180, 17, 180 ,59) %>% 
  #                      addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
  #                      opacity = 1.0, fillOpacity = 1.0, fillColor = ~pal(states$ALAND),
  #                      highlightOptions = highlightOptions(color = "white", weight = 2,
  #                      bringToFront = TRUE)) %>%
  #                      addLegend("bottomright", pal = pal, values = states$ALAND,
  #                      title = "State Land Area (km^2)", 
  #                      labFormat = labelFormat(transform = function(x) 0.000001*x),
  #                      opacity = 1)

  #no highlighting for now, will add highlighting and dynamic data floater later
  map <- leaflet(states) %>% addTiles() %>% setView(-94.85, 38, zoom = 4) %>%
                       setMaxBounds(-180, 17, 180 ,59) %>%
                       addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                       opacity = 1.0, fillOpacity = 0.5, fillColor = ~pal(states$ALAND)) %>%
                       addLegend("bottomright", pal = pal, values = states$ALAND,
                       title = "State Land Area (km^2)",
                       labFormat = labelFormat(transform = function(x) 0.000001*x),
                       opacity = 0.5)
  
  output$myMap = renderLeaflet(map)
  

  # # input$map_shape_mouseover gets updated a lot, even if the id doesn't change.
  # # We don't want to update the polygons and stateInfo except when the id
  # # changes, so use values$highlight to insulate the downstream reactives (as
  # # writing to values$highlight doesn't trigger reactivity unless the new value
  # # is different than the previous value).
  # observe({
  #   values$highlight <- input$map_shape_mouseover$id
  # })
  # 
  # # Dynamically render the box in the upper-right
  # output$stateInfo <- renderUI({
  #   if (is.null(values$highlight)) {
  #     return(tags$div("Hover over a state"))
  #   } else {
  #     # Get a properly formatted state name
  #     stateName <- names(density)[getStateName(values$highlight) == tolower(names(density))]
  #     return(tags$div(
  #       tags$strong(stateName),
  #       tags$div(density[stateName], HTML("people/mi<sup>2</sup>"))
  #     ))
  #   }
  # })
  # 
  # lastHighlighted <- c()
  # # When values$highlight changes, unhighlight the old state (if any) and
  # # highlight the new state
  # observe({
  #   if (length(lastHighlighted) > 0)
  #     drawStates(getStateName(lastHighlighted), FALSE)
  #   lastHighlighted <<- values$highlight
  # 
  #   if (is.null(values$highlight))
  #     return()
  # 
  #   isolate({
  #     drawStates(getStateName(values$highlight), TRUE)
  #   })
  # })
})

