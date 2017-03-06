library(leaflet)


ui <-(fluidPage(

  sidebarLayout(sidebarPanel(
    h3("Display Options", align = "center"),
    
    sliderInput("month","Select Month", min = 1, max = 12, value = 1),
    checkboxInput("normvars","Normalize data by Area", FALSE),
    checkboxInput("showevents", "Show Event Markers", FALSE)
  ),
                
    mainPanel(
      h3("2016 NCDC Hail Report Data", align = "center"),
      
      leafletOutput("myMap", width = "100%", height = 500)
  ), 
 position = "left")
  
 ))

