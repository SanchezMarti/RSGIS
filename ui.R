# RSGIS 0.2

library(shiny)
library(leaflet)
library(rgdal)
library(sp)
library(markdown)
library(shinythemes)
library(shinyjs)

navbarPage(theme = shinytheme("cerulean"), "RSGIS 0.2", id="menu",
           navbarMenu( "Archivo",
                       tabPanel("Añadir shp", value="shp", useShinyjs()),
                       tabPanel("Ver DBF", value="dbf"),
                       tabPanel("Añadir coordenadas", value="puntos")),
           navbarMenu("Editar",
                      tabPanel("Editar Puntos",  value="edit.puntos"),
                      tabPanel("Editar Datos", value="edit.datos")),
           tabPanel("Variables", value="variables"),
           navbarMenu("Mapas temáticos",
                      tabPanel("Niveles", value="tema.lev"),
                      tabPanel("Bins", value="tema.qui")),
           navbarMenu("Conglomerados",
           tabPanel("Conglomerados", value="conglomerados"),
           tabPanel("Summary", value="helpconglo")),
           tabPanel("Rutas", value="rutas", tags$script(src="GeoLoc.js")),
           tabPanel(title = "", value="HELP", icon = icon("fas fa-info-circle")),
           tabPanel(title = "", value="reinicio", icon = icon("refresh")),
           tabPanel(title = "", value="contact", icon = icon("fas fa-question")),
           mainPanel(leafletOutput("SHPinput"), width = 12))
