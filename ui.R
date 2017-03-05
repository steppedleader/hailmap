


library(leaflet)


ui <-(fluidPage(

  sidebarLayout(sidebarPanel(
    h3("Display Options", align = "center"),
    sliderInput("month","Select Month", min = 1, max = 12, value = 1),
    checkboxGroupInput("normvars","Normalization Options", 
                       c("By Population" = "pop", "By Area" = "area"))
  ),
                
    mainPanel(style="background: #ddd;",
      h3("2016 NCDC Hail Report Data", align = "center"),
      
  #my code with newer leaflet stuff
  leafletOutput("myMap", width = "100%", height = 500)
  #end my code

  #   absolutePanel(
  #   right = 520, top = 450, width = 350, class = "floater",
  #   
  #   h4("Number Of Reported Severe Hail Events"),
  #   uiOutput("stateInfo")
  # )
  

  ), 
 position = "left")
  ))

