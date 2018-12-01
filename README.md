# RSGIS
Un SIG programado en R y usando Shiny. La finalidad de este software es crear una herramienta de Sistemas de Información Geográfica online.

## Archivos necesarios para ejecutar
- Server y UI en R.

- Para iniciar el software necesita unos archivos shapefile y un csv, llamados RMSHAPE y PRUEBA, respectivamente.

- Ayuda e inicio escritos en md.

- El código escrito en javascript llamado GeoLoc, lo copie de StackOverFlow, pero no recuerdo quien lo escribio, mil gracias a su autor.

## Archivo
Sube tus archivos, visualiza la base de datos y descarga tu mapa.

### Añadir shp
Este es el primer paso que debes seguir, ya que el resto de opciones dependen de que subas los archivos shapefile. Debes subir los archivos con las siguientes extensiones: **shp**, **dbf**, **shx** y **prj**.

### Añadir coordenadas
Añade unas coordenadas a tu shapefile, para este caso debes subir un archivo csv con las columnas siguiendo este orden: **X**, **lon**, **lat**.

### Ver DBF
Permite la visualización interactiva en forma de tabla de la base de datos del shapefile.

## Editar
Edita los puntos y filtra los datos.

### Editar puntos
Puedes editar la anchura, transpariencia y el color de los puntos.

### Editar datos
Mediante esta opción puedes filtrar los datos por filas. Para ello señala una columna y el valor o valores que quieres visualizar.

## Mapas Temáticos
Crea y descargate un mapa temático basado en la selección de una variable. Si seleccionas más de una variable, solo se considera la primera.

### Por nivel
Crea un mapa temático de la variable seleccionada según sus niveles.

### Por quintil
Crea un mapa temático de la variable seleccinada según su distribución por quintiles.

## Variables
Selecciona las variables para el análisis de conglomerados jerarquicos.

## Conglomerados
Realiza análisis de conglomerados con las variables seleccionadas.

### Conglomerados
**Distancia**
Para calcular las distancias puedes seleccionar entre los distintos métodos: ecledianas, máximas y manhattan.

**Aglomeración**
Para la aglomeración puedes seleccinar entre los distintos métodos: Ward, completo y promedio.

**Nº de conglomerados**
Selecciona el número de conglomerados a formar.

**Hacer conglomerados**
Para hacer los conglomerados debes pulsar el botón conglomerados.

**Descargar conglomerados**
Pulse el botón descargar, para descargar un csv añadiendole a tus datos una columna (CLUSTER) con el número de conglomerados.

### Summary
Obten un resumen de estadísticas descriptivas para cada conglomerado.

## Rutas
Permite la geolocalización y la posterior creación de una ruta hacia el punto que selecciones.
Si pinchas en la ruta obtendras el tiempo aproximado de llegada en coche desde tu posición hasta el punto seleccionado.

La creación de rutas son proporcionadas por Google.

## Reiniciar
Reiniciar todo el software.
