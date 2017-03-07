library(leaflet)


ui <-(fluidPage(

  sidebarLayout(sidebarPanel(
    h3("Display Options", align = "center"),
    
    selectInput("year", "Select Year", choices = c(2016)),
    sliderInput("month","Select Month", min = 1, max = 12, value = 1),
    checkboxInput("showchoro","Show Choropleth Shading", TRUE),
    checkboxInput("normvars","Normalize Choropleth By Area", FALSE),
    checkboxInput("showevents", "Show Event Markers", FALSE)
  ),
                
    mainPanel(
      h3("NCDC Hail Report Data", align = "center"),
      
      leafletOutput("myMap", width = "100%", height = 500)
  ), 
 position = "left")
  
 ))

