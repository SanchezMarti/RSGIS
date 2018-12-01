# RSGIS 0.2

library(shiny)
library(leaflet)
library(rgdal)
library(sp)
library(rsconnect)
library(dplyr)
library(htmlwidgets)
library(webshot)
library(shinyjs)
library(rmarkdown)
library(ggmap)
library(FactoMineR)
library(colourpicker)
library(knitr)


shape <- readOGR(dsn="RMSHAPE.shp", layer="RMSHAPE", encoding = "ESRI Shapefile")
shape <- spTransform(shape, CRS("+init=epsg:4326"))
shape@data$CLUSTER <- rep(1, length(shape@data[,1]))
paletaCLUS <- colorFactor(topo.colors(1), shape@data$CLUSTER)
shape <-NULL
tmpoint <- read.csv ("PRUEBA.csv")
radio <- NULL
transp <- NULL
colorp <- NULL

shinyServer(function(session, input, output) {
        MapReactive <-  reactive({
        
        myshape<- input$inputdata
        if (is.null(myshape)) 
            return(NULL)       
        
        dir<-dirname(myshape[1,4])
        
        for ( i in 1:nrow(myshape)) {
            file.rename(myshape[i,4], paste0(dir,"/",myshape[i,1]))}
        
        getshp <- list.files(dir, pattern="*.shp", full.names=TRUE)
        shape <<-readOGR(getshp)
        shape <<- spTransform(shape, CRS("+init=epsg:4326"))
        shapeDBF <<- shape@data
        contenido <- paste ( "<b>DATOS</b>", br(),
                                     "<b> ID</b>", shape@data[,1] , br())
        leaflet()%>% addPolygons(data = shape, popup=contenido)%>%
            addProviderTiles("Esri.WorldImagery", group="Satelite") %>%
            addTiles(options = providerTileOptions(noWrap = TRUE), group="StreetMap") %>%
            hideGroup("Satelite") %>%
            hideGroup("StreetMap") %>%
            addLayersControl(overlayGroups = c("Satelite","StreetMap"), options = layersControlOptions(collapsed = FALSE))
        
    })
        # Modal SHP
        observeEvent(input$menu, {
            if (input$menu=="shp"){
                showModal(modalDialog(
                    title = "Añadir shapefiles",
                    div(style="display:inline-block;",fileInput("inputdata", "Sube los archivos",accept=c(".shp",".dbf",".sbn",".sbx",".shx",".prj"), multiple=TRUE, buttonLabel="Subir", placeholder = "Ningún archivo seleccionado"),
                        helpText(strong("Nota:"),"Deben estar como mínimo las extensiones shp, dbf, shx y prj")),
                    footer=modalButton("Aceptar"),
                    easyClose = TRUE
                ))}
        })
        
        # Modal DBF
        observeEvent(input$menu, 
          {
            if (input$menu=="dbf"){
                showModal(modalDialog(
                    title = "Base de datos",
                    size="l",
                    div(style = 'overflow-x: scroll',DT::dataTableOutput("inputDBF")),
                    footer=modalButton("Aceptar"),
                    easyClose = TRUE
                ))}
        })
        
        DTDBF <- eventReactive(input$inputdata,{shapeDBF})
        
        output$inputDBF = DT::renderDataTable({DTDBF()})

        output$SHPinput <- renderLeaflet({MapReactive()})
        
        # Modal punto
        observeEvent(input$menu, {
            if (input$menu=="puntos"){
                showModal(modalDialog(
                    title = "Añadir coordenadas",
                    div(style="display:inline-block;",fileInput("inputpoint", "Sube unas coordenadas", accept = c("text/csv",
                                                                                                                  "text/comma-separated-values,text/plain",
                                                                                                                  ".csv"), buttonLabel="Subir", placeholder = "Ningún archivo seleccionado"),
                        helpText(strong("Nota:"),"Selecciona un csv con las columnas siguiendo este orden: X, lon, lat")),
                    div(style="display:inline-block;",radioButtons("SEP", "Separador",
                                                                   choices = c(Coma = ",",
                                                                               Puntocoma = ";",
                                                                               Tabulador = "\t"),
                                                                   selected = ",", inline=TRUE)),
                    div(style="display:inline-block; width: 50px;",HTML("<br>")),
                    div(style="display:inline-block;",radioButtons("DEC", "Decimales",
                                                                   choices = c(Punto = ".",
                                                                               Coma = ","),
                                                                   selected = ".", inline=TRUE)),
                    footer=modalButton("Aceptar"),
                    easyClose = TRUE
                ))}
        })
        
    observeEvent(input$inputpoint,{
        mypoint <- input$inputpoint
        if (is.null(mypoint))
            return(NULL)
        tmpoint <<- read.csv (mypoint$datapath)
        names(tmpoint) <<- c("X","lon", "lat")
        contenido.tmpoint <- paste("<b> ID </b>", tmpoint$X)
        radio <- 24
        transp <- 0.8
        colorp <- "red"
        leafletProxy("SHPinput") %>% clearGroup(group="Puntos") %>%  addCircles(lng=tmpoint$lon, lat=tmpoint$lat, popup=contenido.tmpoint, fillColor = colorp,
                                                fillOpacity = transp, fill=TRUE, stroke = FALSE , weight = 1, radius= radio, group="Puntos")
    })
    
    # Modal Editar Puntos
    observeEvent(input$menu, {
        updateSliderInput(session, "radio", label = "Radio puntos (m.)", min = 1, max = 10000, value = input$radio)
        updateSliderInput(session, "transp", label = "Transparencia", min = 0, max = 1, value = input$transp)
        updateColourInput(session, "colorp", label= "Selecciona un color", value=input$colorp, palette="limited")
        radio <<- input$radio
        transp <<- input$transp
        colorp <<- input$colorp
        if (input$menu=="edit.puntos"){
            showModal(modalDialog(
                title = "Editar puntos",
                div(style="display:inline-block;", sliderInput("radio", label = "Radio puntos (m.)",
                                                               min = 1, max = 10000, value = 24)),
                div(style="display:inline-block; width: 100px;",HTML("<br>")),
                div(style="display:inline-block;", sliderInput("transp", label = "Transpariencia",
                                                               min = 0, max = 1, value = 0.8)),
                div(style="display:inline-block; width: 100px;",HTML("<br>")),
                div(style="display:inline-block;", colourInput("colorp", label= "Selecciona un color", value="red", palette="limited")),
                div(style="display:inline-block; width: 200px;",HTML("<br>")),
                div(style="display:inline-block;",actionButton("editPunto", "Editar puntos")),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    
    observeEvent(input$editPunto,{
        mypoint <- input$inputpoint
        if (is.null(mypoint))
            return(NULL)
        tmpoint <<- read.csv (mypoint$datapath)
        names(tmpoint) <<- c("X","lon", "lat")
        contenido.tmpoint <- paste("<b> ID </b>", tmpoint$X)
        radio <<- input$radio
        transp <<- input$transp
        colorp <<- input$colorp
        leafletProxy("SHPinput") %>% clearGroup(group="Puntos") %>%  addCircles(lng=tmpoint$lon, lat=tmpoint$lat, fillColor = colorp,
                                                                                fillOpacity = transp, fill=TRUE, stroke = FALSE , weight = 1, radius= radio, group="Puntos")
    })
    
    # Modal Editar Datos
    observeEvent(input$menu, {
        updateSelectInput(session, "queryVAR", "Variable", 
                          choices = names(shape))
        if (input$menu=="edit.datos"){
            showModal(modalDialog(
                title = "Editar datos",
                div(style="display:inline-block;",selectInput("queryVAR", "Selecciona la variable", choices=NULL, multiple=FALSE)),
                div(style="display:inline-block; width: 100px;",HTML("<br>")),
                div(style="display:inline-block;",actionButton("queryup1", "Seleccionar")),
                div(style="display:inline-block;",selectInput("queryN", "Filtrar la variable", choices=NULL, multiple = FALSE)),
                div(style="display:inline-block; width: 100px;",HTML("<br>")),
                div(style="display:inline-block;",actionButton("queryup", "Filtrar Datos")),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    
    
    # Filtrado
    
    ColSel <- eventReactive(input$queryVAR,{
        isolate({if (is.null(shape)) return (NULL)
            as.factor(shape@data[,input$queryVAR])})
    })
    
    observeEvent(input$queryup1,{
        isolate({LqueryVAR <- levels(ColSel())
        updateSelectInput(session, "queryN", "Valor", choices = LqueryVAR)
        })
    })
    
    ValSel <- eventReactive(input$queryN,{
        isolate({if (is.null(shape)) return (NULL)
            which(ColSel()==input$queryN)})
    })
    
    observeEvent(input$queryup,{
        DataSel <<- ValSel()
        shape <<- shape[DataSel,]
        shapeDBF <<- shape@data
        contenidoSEL <- paste ( "<b>DATOS</b>", br(),
                             "<b> ID</b>", shape@data[,1] , br())
        leafletProxy("SHPinput")%>% clearShapes() %>% addPolygons(data = shape, popup=contenidoSEL)
    })
    
    # Modal Selección variables
    observeEvent(input$menu, {
        updateSelectInput(session, "VAR", "Variable", 
                          choices = names(shape))
        if (input$menu=="variables"){
            showModal(modalDialog(
                title = "Variables",
                selectInput("VAR", "Selecciona las variables", choices=NULL, multiple=TRUE),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    
    # Seleccion Variables conglo
    
    VarSel <- reactive({
        shape@data[,input$VAR]
    })
    
    # Mapas Temáticos
    observeEvent(input$menu, {
        if (input$menu=="tema.lev"){
            showModal(modalDialog(
                title = "Mapas por niveles",
                p("Crea un mapa basado en los niveles de la variable seleccionada"),
                div(style="display:inline-block;",actionButton("MAKETEMA.LEV", "Mapa Niveles", icon=icon("gear"))),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    observeEvent(input$menu, {
        if (input$menu=="tema.qui"){
            showModal(modalDialog(
                title = "Mapas por bins",
                p("Crea un mapa basado en la distribución de la variable seleccionada"),
                div(style="display:inline-block;",actionButton("MAKETEMA.QUI", "Mapa Bins", icon=icon("gear"))),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    
    observeEvent(input$MAKETEMA.LEV,{
        TemaSel.FAC <<- as.data.frame(VarSel())
        names (TemaSel.FAC) <<- c("Factor")
        shape@data$Factor <<- as.factor(TemaSel.FAC$Factor)
        Lvl.FAC <- length(levels(shape@data$Factor))
        paletaTEMA.LEV <<- colorFactor(topo.colors(Lvl.FAC), shape@data$Factor)
        contenidoTEMA.LEV <- paste ( "<b>DATOS</b>", br(),
                                 "<b> ID</b>", shape@data[,1] , br(),
                                 "<b>% Variable</b>", shape@data$Factor)
        leafletProxy("SHPinput")%>% clearShapes() %>% addPolygons(data = shape, stroke = TRUE, fillOpacity = 0.8, fill = TRUE,
                                                                  fillColor=~paletaTEMA.LEV(Factor), popup=contenidoTEMA.LEV)%>%
            clearControls() %>%
            addLegend("topright", pal = paletaTEMA.LEV, values =shape@data$Factor,
                      title = "Leyenda Mapa Temático")
    })
    
    observeEvent(input$MAKETEMA.QUI,{
        TemaSel.NUM <<- as.data.frame(VarSel())
        names (TemaSel.NUM) <<- c("TemaSel")
        shape@data$TemaSel <<- as.numeric(as.character(TemaSel.NUM$TemaSel))
        paletaTEMA <<- colorBin("Blues", domain= shape@data$TemaSel, n = 5)
        contenidoTEMA <- paste ( "<b>DATOS</b>", br(),
                                 "<b> ID</b>", shape@data[,1] , br(),
                                 "<b>% Variable</b>", shape@data$TemaSel)
        leafletProxy("SHPinput")%>% clearShapes() %>% addPolygons(data = shape, stroke = FALSE, fillOpacity = 0.8, fill = TRUE,
                                                                  fillColor=~paletaTEMA(TemaSel), popup=contenidoTEMA)%>%
            clearControls() %>%
            addLegend("topright", pal = paletaTEMA, values =shape$TemaSel,
                      title = "Leyenda Mapa Temático")
    })
    
    # Modal Conglomerados
    observeEvent(input$menu, {
        if (input$menu=="conglomerados"){
            showModal(modalDialog(
                title = "Variables",
                div(style="display:inline-block;",radioButtons("MetDist", "Distancias",
                                                               choices = c(euclidean = "euclidean",
                                                                           maximum = "maximum",
                                                                           manhattan = "manhattan"),
                                                               selected = "euclidean", inline=TRUE)),
                div(style="display:inline-block; width: 100px;",HTML("<br>")),
                div(style="display:inline-block;",radioButtons("MetHc", "Aglomeración",
                                                               choices = c(ward.D2 = "ward.D2",
                                                                           complete = "complete",
                                                                           average = "average"
                                                               ),
                                                               selected = "ward.D2", inline=TRUE)),
                div(style="display:inline-block; width: 100px;",HTML("<br>")),
                div(style="display:inline-block;",selectInput("N", "Número de conglomerados", choices= c(2:12))),
                div(style="display:inline-block; width: 50px;",HTML("<br>")),
                div(style="display:inline-block;",actionButton("MAKECLUST", "Conglomerados", icon=icon("gear"))),
                div(style="display:inline-block; width: 50px;",HTML("<br>")),
                div(style="display:inline-block;",downloadButton("DwnCSVConglo", "Descargar")),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    

    observeEvent(input$MAKECLUST,{
        N <- input$N
        distseleccion <- dist (VarSel(), method = input$MetDist)
        hcseleccion <- hclust (distseleccion, method= input$MetHc)
        hcseleccionN <- cutree (hcseleccion, k=N)
        shape@data$CLUSTER <<- as.factor(hcseleccionN)
        paletaCLUS <<- colorFactor(topo.colors(N), shape@data$CLUSTER)
        contenidoCLUS <- paste ( "<b>DATOS</b>", br(),
                                   "<b> ID</b>", shape@data[,1] , br(),
                                   "<b>% Conglomerado</b>", shape@data$CLUSTER)
        leafletProxy("SHPinput")%>% clearShapes() %>% addPolygons(data = shape, stroke = TRUE, fillOpacity = 0.8, fill = TRUE,
                                                                   fillColor=~paletaCLUS(shape@data$CLUSTER), popup=contenidoCLUS)%>%
            clearControls() %>%
            addLegend("topright", pal = paletaCLUS, values =shape@data$CLUSTER,
                      title = "Leyenda conglomerados")
    })
    
    # Summary
    
    HelpSel <- reactive ({
        if (is.null(shape@data$CLUSTER)) return (NULL)
        input$N
        VarSel.NUM <<- as.data.frame(VarSel())
        VarSel.NUM[] <<- as.numeric(as.character(unlist(VarSel.NUM)))
        by (VarSel.NUM, shape@data$CLUSTER, summary)
    })
    
    output$HelpConglo <- renderPrint({
        if (!is.null(shape)) return(HelpSel())})
    
    # Modal Ayuda Conglo
    observeEvent(input$menu, {
        if (input$menu=="helpconglo"){
            showModal(modalDialog(
                title = "Summary Conglomerados",
                size="l",
                verbatimTextOutput("HelpConglo"),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    
    
    # Modal Rutas
    observeEvent(input$menu, {
        if (input$menu=="rutas"){
            showModal(modalDialog(
                title = "Rutas",
                div(style="display:inline-block;",actionButton("geoloc", "Localizame", class="btn btn-primary", onClick="shinyjs.geoloc()")),
                div(style="display:inline-block; width: 200px;",HTML("<br>")),
                div(style="display:inline-block;",numericInput("X", label = h3("Ir al punto:"), min=1, max=10000, value= 100)),
                div(style="display:inline-block; width: 200px;",HTML("<br>")),
                div(style="display:inline-block;",actionButton("GORUTA", "Ruta")),
                footer=modalButton("Aceptar"),
                easyClose = TRUE
            ))}
    })
    
    # Rutas
    
    observe({
        if(!is.null(input$lat)){
            
            lat <- input$lat
            lng <- input$long
            acc <- input$accuracy
            time <- input$time
            leafletProxy("SHPinput")%>%
                clearGroup(group="pos") %>% 
                addMarkers(lng=lng, lat=lat, popup=paste("Mi localización es:","<br>",
                                                         lng,"Lon","<br>",
                                                         lat,"Lat", "<br>",
                                                         "Altitud:",  "<br>",
                                                         acc, "metros"),
                           group="pos")
            
        }
    })
    
    observe({
        input$GORUTA
        isolate({
            if(!is.null(input$lat)){
                
                lat <- input$lat
                lng <- input$long
                acc <- input$accuracy
                time <- input$time
                Coor.Texto <- input$X
                Coor.selec <- tmpoint[tmpoint$X==Coor.Texto,]
                pfinal <- as.matrix (as.numeric(cbind (Coor.selec$lon,Coor.selec$lat)))
                geofinal <- revgeocode (pfinal)
                
                pinicio <- as.matrix (as.numeric(cbind (lng,lat)))
                geoinicio <- revgeocode (pinicio)
                if(is.character(geoinicio)){
                    if(is.character(geofinal)){
                        route_df <- route (geoinicio, geofinal , structure="route")
                        minutes <- round(sum(route_df$minutes, na.rm=T),0)
                        leafletProxy("SHPinput")%>%
                            clearGroup(group="route") %>% 
                            addMarkers(lng=lng, lat=lat, popup=paste("Mi localización es:","<br>",
                                                                     lng,"Lon","<br>",
                                                                     lat,"Lat", "<br>",
                                                                     "Altitud:",  "<br>",
                                                                     acc, "metros"),
                                       group="route") %>% 
                            addPolylines(route_df$lon, route_df$lat, color="magenta", popup=paste("Vas a tardar:",minutes, "minutos." ), group="route")
                        
                    }}
            }
        })
        
    })

    
    # Descargas
    
    output$DwnCSVConglo <- downloadHandler(filename = function() {
        paste("Conglomerados", "_" , Sys.Date(), ".csv", sep="")},
        content = function(file) {write.csv(shape@data, file)})
    
    
    # Contacto
    observeEvent(input$menu, {
        if (input$menu=="contact"){
            showModal(modalDialog(
                title = "Contactame",
                footer=modalButton("Aceptar"),
                p("Este software está siendo desarrollado por Jose Antonio Sánchez Martí, doctorando de la Universidad de Murcia, departamento de economía aplicada."),
                p("El correo para cualquier duda, comentario o sugerencia es el siguiente:", strong("joseantonio.sanchez7@um.es")),
                easyClose = TRUE
            ))}
    })
    
    # Ayuda
    observeEvent(input$menu, {
        if (input$menu=="HELP"){
            showModal(modalDialog(
                title = "Ayuda",
                footer=modalButton("Aceptar"),
                size="l",
                includeMarkdown("Ayuda.md"),
                easyClose = TRUE
            ))}
    })

# Reinciamos el programa
    observe({
        if (input$menu == "reinicio"){
            leafletProxy("SHPinput") %>% clearShapes() %>% clearControls()
            reset("inputdata")
            reset("inputpoint")
            reset("MetDist")
            reset("MetHc")
            reset("SEP")
            reset("DEC")
            reset("VAR")
            reset("Ayuda")
            reset("N")
            reset("transp")
            reset("colop")
            reset("radio")
            reset("X")
        }
    })
    
    })
