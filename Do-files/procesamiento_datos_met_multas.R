
rm(list = ls())
gc()
getwd()
setwd("C:/Users/71547829/Downloads/1. Códigos R")

require(pacman)
p_load(foreign, tidyverse, rio, here, dplyr, viridis, readxl, stringr, RColorBrewer, ggcorrplot,  
       flextable, officer, classInt, foreign, stargazer, sf, mapview, leaflet, writexl, lmtest,
       tseries, car, haven, officer, xlsx, openxlsx, httr)


#####################################################################################################################################################
### PARTE 1: Construcción de la base de informes para el cálculo de multas del primer muestreo, la cual contó con dos fases.
#####################################################################################################################################################


# Carga de las bases antiguas
url1 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Informes_2022.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url1, write_disk(temp_file, overwrite = TRUE))
Consolidado1 <- read_excel(temp_file, sheet = "Componentes")  
Consolidado1$Año <- 2022
rm(temp_file, url1)

url2 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Informes_2023.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url2, write_disk(temp_file, overwrite = TRUE))
Consolidado2 <- read_excel(temp_file, sheet = "Componentes")  
Consolidado2$Año <- 2023
rm(temp_file, url2)

url3 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Informes_2024.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url3, write_disk(temp_file, overwrite = TRUE))
Consolidado3 <- read_excel(temp_file, sheet = "Componentes")  
Consolidado3$Año <- 2024
rm(temp_file, url3)

# Carga de las bases nuevas
url4 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Info_2022.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url4, write_disk(temp_file, overwrite = TRUE))
Consolidado4 <- read_excel(temp_file, sheet = "Consolidado")  
Consolidado4$Año <- 2022
rm(temp_file, url4)

url5 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Info_2023.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url5, write_disk(temp_file, overwrite = TRUE))
Consolidado5 <- read_excel(temp_file, sheet = "Consolidado")  
Consolidado5$Año <- 2023
rm(temp_file, url5)

url6 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Info_2024.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url6, write_disk(temp_file, overwrite = TRUE))
Consolidado6 <- read_excel(temp_file, sheet = "Consolidado")  
Consolidado6$Año <- 2024
rm(temp_file, url6)

# Carga de información de RUIAS
url7 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20sustento/RUIAS-CSEP.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url7, write_disk(temp_file, overwrite = TRUE))
RUIAS <- read_excel(temp_file, sheet = "RUIAS")  
rm(temp_file, url7)


# Consolidando la información
Antigua <- rbind(Consolidado1, Consolidado2, Consolidado3)
rm(Consolidado1, Consolidado2, Consolidado3)

Nueva <- rbind(Consolidado4, Consolidado5, Consolidado6)
rm(Consolidado4, Consolidado5, Consolidado6)

#Exportamos la información generada en la muestra
write_xlsx(Antigua, "primera_revision.xlsx")
write_xlsx(Nueva, "segunda_revision.xlsx")


# Filtrando la información necesaria
Antigua <- Antigua %>% 
  filter(Detalle != "Eliminar" | is.na(Detalle))

Antigua <- Antigua %>% 
  filter(Filtro=="Cálculo de multa")

Nueva <- Nueva %>% 
  filter(Filtro=="Cálculo de multa")

# Edición de base Antigua
colnames(Antigua)[colnames(Antigua) == "Sub_extremo"] <- "Extremo"
Antigua <- Antigua %>% select(-Detalle, -Observaciones)
Antigua$Datos <- "Primera fase"

# Edición de base Nueva
Nueva <- Nueva %>% select(-"Sub extremo")
Nueva$Datos <- "Segunda fase"

# Append principal
CFinal <- rbind(Antigua, Nueva)

# Ediciones extra
colnames(CFinal)[colnames(CFinal) == "ID"] <- "Index"
CFinal$Index <- as.character(CFinal$Index)
colnames(CFinal)[colnames(CFinal) == "Expedientes"] <- "Expediente"

#Eliminamos las bases trabajadas
rm(Antigua, Nueva)

#Guardamos la base de datos
write_xlsx(CFinal, "baseunida.xlsx")

###### Seleccionando las variables a usar de la base del RUIAS ########
RFinal <- RUIAS %>% dplyr::select("ID", "Administrado", "RUC", "Sector económico", "Departamento",
                                  "Provincia", "Distrito", "Infracción cometida sancionada (Clasificación de 11)",
                                  "Infracción cometida sancionada (Clasificación de 19)", 
                                  "Inicio de supervisión", "Fin de supervisión", "Fecha de notificación...23",
                                  "Documento de inicio", "Fecha de emisión",
                                  "N° de Resolución de Responsabilidad Administrativa", "Fecha de la Resolución...38", 
                                  "Fecha de notificación...39")

colnames(RFinal)[colnames(RFinal) == "ID"] <- "Index"
colnames(RFinal)[colnames(RFinal) == "Sector económico"] <- "SectorEco"
colnames(RFinal)[colnames(RFinal) == "Inicio de supervisión"] <- "InicioSup"
colnames(RFinal)[colnames(RFinal) == "Fin de supervisión"] <- "FinSup"
colnames(RFinal)[colnames(RFinal) == "Fecha de notificación...23"] <- "InicioPAS"
colnames(RFinal)[colnames(RFinal) == "Infracción cometida sancionada (Clasificación de 11)"] <- "Incumplimiento_11"
colnames(RFinal)[colnames(RFinal) == "Infracción cometida sancionada (Clasificación de 19)"] <- "Incumplimiento_19"
colnames(RFinal)[colnames(RFinal) == "Fecha de notificación...23"] <- "Fecha_Notificacion_23"
colnames(RFinal)[colnames(RFinal) == "Fecha de notificación...39"] <- "Fecha_Notificacion_39"
colnames(RFinal)[colnames(RFinal) == "Fecha de la Resolución...38"] <- "Fecha_Resolucion"
colnames(RFinal)[colnames(RFinal) == "N° de Resolución de Responsabilidad Administrativa"] <- "Nro_Resolucion"
colnames(RFinal)[colnames(RFinal) == "Documento de inicio"] <- "Documento_Inicio"
colnames(RFinal)[colnames(RFinal) == "Fecha de emisión"] <- "Fecha_Emision"

RFinal$Index <- as.character(RFinal$Index)

# Fusionando ambas bases
CFinal$Index[is.na(CFinal$Index)] <- 0
FINAL <-left_join(x = CFinal, y = RFinal, by="Index")

FINAL <- FINAL %>%
  mutate(Merge = if_else(!is.na(Departamento), 1, 0)) 

# Eliminando los objetos que no necesitamos
rm(CFinal, RFinal, RUIAS)

# Se define el tipo de variables numéricas

FINAL$Sancion_total <- as.numeric(FINAL$Sancion_total)
FINAL$Multa_Final <- as.numeric(FINAL$Multa_Final)
FINAL$Prob_Detección <- as.numeric(FINAL$Prob_Detección)
FINAL$Beneficio_ilícito <- as.numeric(FINAL$Beneficio_ilícito)
FINAL$T_meses <- as.numeric(FINAL$T_meses)

#Formato de la variable sector económico
FINAL <- FINAL %>%
  mutate(SectorEco = tolower(SectorEco))

FINAL$SectorEco <- sapply(FINAL$SectorEco, function(x) {
  paste(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x))), sep = "")
})

#Se eliminan los valores de multas iguales a cero
FINAL <- FINAL %>% filter(Multa_Final != 0)

# Se realiza una tabla de la variable merge 
table(FINAL$Merge)

# Fusionando el Tipo de Empresa (restante: Index 7020)
url8 <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/Bases/Exceles/Tipo_Empresas.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
GET(url8, write_disk(temp_file, overwrite = TRUE))
Tamaño <- read_excel(temp_file, sheet = "Final")  
rm(temp_file, url8)
FINAL <-left_join(x = FINAL, y = Tamaño, by="Administrado")
rm(Tamaño)
#View(FINAL[is.na(FINAL$tipo_actividad), ])
FINAL$tipo_actividad <- ifelse(FINAL$Index == "7020", "actividad empresarial", FINAL$tipo_actividad)
FINAL$tipo_persona <- ifelse(FINAL$Index == "7020", "persona jurídica", FINAL$tipo_persona)
table(FINAL$tipo_actividad, FINAL$tipo_persona, useNA = "ifany")
FINAL$Colapsar <- ifelse(FINAL$Colapsar == "Máximo", "Maximo", FINAL$Colapsar)
table(FINAL$Colapsar)

###################################
###### Fechas de informes #########
###################################

# Bucle para descargar y leer los archivos por año
years <- c(2022, 2023, 2024)
for (year in years) {
  url <- paste0("https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/Fechas/Fecha_", year, ".xlsx")
  temp_file <- tempfile(fileext = ".xlsx")
  GET(url, write_disk(temp_file, overwrite = TRUE))
  assign(paste0("F", year), read_excel(temp_file, sheet = as.character(year)))
  rm(temp_file, url)
}
rm(year, years)

Fechas1 <- rbind(F2022, F2023, F2024)
rm(F2022, F2023, F2024)

Fechas1 <- Fechas1 %>% dplyr::select(Informes, Fecha_Informe)

years <- c(2022, 2023, 2024)
for (year in years) {
  url <- paste0("https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/Fechas/Fecha_", year, "b.xlsx")
  temp_file <- tempfile(fileext = ".xlsx")
  GET(url, write_disk(temp_file, overwrite = TRUE))
  assign(paste0("F", year), read_excel(temp_file, sheet = as.character(year)))
  rm(temp_file, url)
}
rm(year, years)

Fechas2 <- rbind(F2022, F2023, F2024)
colnames(Fechas2)[colnames(Fechas2) == "Fecha"] <- "Fecha_Informe"
Fechas2 <- Fechas2 %>% dplyr::select(Informes, Fecha_Informe)
rm(F2022, F2023, F2024)

Fechas <- rbind(Fechas1, Fechas2)
rm(Fechas1, Fechas2)

FINAL <-left_join(x = FINAL, y = Fechas, by="Informes")
rm(Fechas)

#Se observa ningún missing de la variable Fecha_Informe
table(is.na(FINAL$Fecha_Informe))
#View(FINAL[is.na(FINAL$Fecha_Informe), ])

###################################
##### Factores de graduación ######
###################################

years <- c(2022, 2023, 2024)
Factores <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Informes_"
for (year in years) {
  url <- paste0(Factores, year, ".xlsx")
  temp_file <- tempfile(fileext = ".xlsx")
  GET(url, write_disk(temp_file, overwrite = TRUE))
  assign(paste0("G", year), read_excel(temp_file, sheet = "Graduacion"))
  rm(temp_file, url)
}

rm(Factores, year, years)

# Quitando de las bases la variable Observaciones

G2022$Observaciones <- NULL 
G2024$Observaciones <- NULL 

# Haciendo un append
Aglomerado1 <- rbind(G2022, G2023, G2024)
rm(G2022, G2023, G2024)

#Eliminamos la categoría "Eliminar" de la variable Detalle
table(Aglomerado1$Detalle)
Aglomerado1 <- Aglomerado1 %>% 
  filter(Detalle != "Eliminar")

#Mantenemos la categoría Cálculo de multa dento de la variable Filtro
table(Aglomerado1$Filtro)
Aglomerado1 <- Aglomerado1 %>% 
  filter(Filtro=="Cálculo de multa")

# Seleccionando las variables a emplear
Aglomerado1 <- Aglomerado1 %>% dplyr::select("ID","Informes", "Imputacion", "Factores_agravantes", "Categoria_FA", "% FA")
table(Aglomerado1$Factores_agravantes, useNA = "ifany")

# Importando Los nuevos Factores del segundo proceso de revisión de informes
years <- c(2022, 2023, 2024)
Factores <- "https://raw.githubusercontent.com/PaoloValcarcel/OEFA_SMER/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Info_"
for (year in years) {
  url <- paste0(Factores, year, ".xlsx")
  temp_file <- tempfile(fileext = ".xlsx")
  GET(url, write_disk(temp_file, overwrite = TRUE))
  assign(paste0("G", year), read_excel(temp_file, sheet = "Graduación"))
  rm(temp_file, url)
}
rm(Factores, year, years)

Aglomerado2 <- rbind(G2022, G2023, G2024)
rm(G2022, G2023, G2024)

#Se mantienen solo los cálculos de multa
table(Aglomerado2$Filtro)
Aglomerado2 <- Aglomerado2 %>% 
  filter(Filtro=="Cálculo de multa")

#Renombramos una variable y nos quedamos con las variables relevantes
colnames(Aglomerado2)[colnames(Aglomerado2) == "Correlativo"] <- "ID"
Aglomerado2 <- Aglomerado2 %>% dplyr::select("ID","Informes", "Imputacion", "Factores_agravantes", "Categoria_FA", "% FA")

Aglomerado1$Datos <- "Primera fase"
Aglomerado2$Datos <- "Segunda fase"

# Se hace el append de las dos bases de factores
FACTORES <- rbind(Aglomerado1, Aglomerado2)
rm(Aglomerado1, Aglomerado2)

#Se coloca cero en %FA cuando la categoría_FA es NA
FACTORES <- FACTORES %>%
  mutate(`% FA` = ifelse(is.na(Categoria_FA), 0, `% FA`))

#Se realiza una 
FACTORES <- FACTORES %>%
  mutate(Factores_agravantes = dplyr::recode(Factores_agravantes,
                                             "F.1.1" = "F1 1.1",
                                             "F.1.2" = "F1 1.2",
                                             "F.1.3" = "F1 1.3",
                                             "F.1.4" = "F1 1.4",
                                             "F.1.7" = "F1 1.7"
  ))

table(FACTORES$Factores_agravantes)

# 1. Leer archivo remoto desde GitHub
urlp <- "https://github.com/PaoloValcarcel/OEFA_SMER/raw/refs/heads/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Muestra_Final_Paolo_vf2.xlsx"
tmp <- tempfile(fileext = ".xlsx")
GET(urlp, write_disk(tmp, overwrite = TRUE))

# 2. Leer hojas de informes por año
m2024p  <- read_excel(tmp, sheet = "2024")   %>% mutate(Año = 2024)

#Se analiza cuantos informes distintos hay por año en la base final
FINAL %>%
  group_by(Año) %>%
  summarise(Informes_distintos = n_distinct(Informes))

# Comprobamos que solo quedan 132 informes distintos en la base de Factores, eliminando aquellos de 2024
n_distinct(FACTORES$Informes)

# Filtrar FINAL para conservar solo los Informes presentes en m2024p
FINAL <- FINAL %>%
  filter(
    (Año != 2024) | (Año == 2024 & Informes %in% m2024p$Informes)
  )

# Nos quedamos solo con losinformes de FINAL para los FACTORES
FACTORES <- FACTORES %>%
  filter(Informes %in% FINAL$Informes)

# Comprobamos cuántos informes quedaron
n_distinct(FINAL$Informes)
n_distinct(FACTORES$Informes)

################################################################################
### COMPROBACIÓN DE LA CALIDAD DE LOS DATOS (Primera fase)
################################################################################

# Número de registros con "NANA" en SectorEco
sum(FINAL$SectorEco == "NANA", na.rm = TRUE)

# Sectores únicos
table(FINAL$SectorEco, useNA = "ifany")
unique(FINAL$SectorEco)

# Número de sectores distintos
n_distinct(FINAL$SectorEco)

# Número de informes distintos para los años 2022 y 2023
n_distinct(FINAL$Informes)
n_distinct(FACTORES$Informes)

################################################################################
### PARTE 2: Construcción de la base de datos de IC del segundo proceso de muestreo
################################################################################

# 1. Leer archivo remoto desde GitHub
url <- "https://github.com/PaoloValcarcel/OEFA_SMER/raw/refs/heads/main/Paolo/C%C3%B3digo%20Final/Bases%20Finales/Muestra_Final_Paolo_vf2.xlsx"
tmp <- tempfile(fileext = ".xlsx")
GET(url, write_disk(tmp, overwrite = TRUE))

# 2. Leer hojas de informes por año
m2022  <- read_excel(tmp, sheet = "2022")   %>% mutate(Año = 2022)
m2023  <- read_excel(tmp, sheet = "2023")   %>% mutate(Año = 2023)
m2025  <- read_excel(tmp, sheet = "2025")   %>% mutate(Año = 2025)
m2022g <- read_excel(tmp, sheet = "2022-G") %>% mutate(Año = 2022)
m2023g <- read_excel(tmp, sheet = "2023-G") %>% mutate(Año = 2023)
m2025g <- read_excel(tmp, sheet = "2025-G") %>% mutate(Año = 2025)


# 3. Funciones de limpieza
limpiar_df <- function(df) {
  df %>%
    rename_with(~ ifelse(.x == "Sector_Economico", "SectorEco", .x)) %>%
    select(-any_of("observaciones"))
}

fix_numeric <- function(df) {
  df %>%
    mutate(
      Multa         = as.numeric(Multa),
      Multa_Final   = as.numeric(Multa_Final),
      Sancion_total = as.numeric(Sancion_total),
      Extremo       = as.character(Extremo)   # asegurar texto en todos
    )
}

# 4. Aplicar términos homogéneos, eliminar variable observaciones y formato de variables
list_m <- list(m2022, m2023, m2025, FINAL)

list_m <- lapply(list_m, function(df) {
  df %>% limpiar_df() %>% fix_numeric()
})

# Reasignamos las bases procesadas
m2022            <- list_m[[1]]
m2023            <- list_m[[2]]
m2025            <- list_m[[3]]
FINAL <- list_m[[4]]

# Confirmar que Extremo quedó como variable character
sapply(list(
  FINAL = FINAL,
  m2022 = m2022,
  m2023 = m2023,
  m2025 = m2025
), function(df) class(df$Extremo))

################################################################################
### VERIFICAR Y ELIMINAR REPETIDOS ENTRE BASE PRINCIPAL Y AÑOS
################################################################################

ibase <- unique(FINAL$Informes)

# --- Detectar repetidos por año --- (4 en 2022 y 3 en 2023)
rep_2022 <- intersect(m2022$Informes, ibase)
rep_2023 <- intersect(m2023$Informes, ibase)

# --- Filtrar para evitar informes repetidos en la base de Factores de graduación ---
m2022g <- filter(m2022g, !Informes %in% rep_2022)
m2023g <- filter(m2023g, !Informes %in% rep_2023)

# --- Filtrar informes repetidos en la base de multas ---
m2022  <- filter(m2022,  !Informes %in% rep_2022)
m2023  <- filter(m2023,  !Informes %in% rep_2023)

# --- Confirmación rápida (que no queden repetidos en informes en los factores de graduación) ---
stopifnot(
  length(intersect(m2022g$Informes, ibase)) == 0,
  length(intersect(m2023g$Informes, ibase)) == 0
)

# --- Confirmación rápida (que no queden repetidos en informes de la base de multas) ---
stopifnot(
  length(intersect(m2022$Informes, ibase)) == 0,
  length(intersect(m2023$Informes, ibase)) == 0
)

################################################################################
### UNIR INFORMES Y FACTORES
################################################################################

# Se unen las bases que contienen la información del valor de la multa
FINAL <- bind_rows(FINAL, m2022, m2023, m2025) 
n_distinct(FINAL$Informes)
FINAL %>%
  group_by(Año) %>%
  summarise(
    informes_distintos = n_distinct(Informes)
  )
rm(m2022, m2023, m2024,m2025)

table(FINAL$SectorEco)
FINAL <- FINAL %>% 
  mutate(SectorEco = dplyr::recode(
    SectorEco, "Residuos Sólidos" = "Residuos sólidos", 
    "Consultoras Ambientales" = "Consultoras ambientales"))

# Se unen las bases de factores de graduación
FACTORES <- bind_rows(FACTORES, m2022g, m2023g, m2025g)
n_distinct(FACTORES$Informes)
FINAL %>%
  group_by(Año) %>%
  summarise(
    informes_distintos = n_distinct(Informes)
  )
rm(m2022g, m2023g ,m2024g, m2025g)

unique(FACTORES$Factores_agravantes)

FACTORES <- FACTORES %>%
  mutate(Factores_agravantes = dplyr::recode(Factores_agravantes, 
                                             "F.1.1" = "F1 1.1", 
                                             "F.1.2" = "F1 1.2", 
                                             "F.1.3" = "F1 1.3", 
                                             "F.1.4" = "F1 1.4",
                                             "F.1.7" = "F1 1.7" ))

################################################################################
### PARTE 2: Corrección de valores de factores de graduación inconsistentes
################################################################################

# Instalar y cargar librería janitor (solo instalar si no está ya instalada)
if (!require(janitor)) install.packages("janitor")
library(janitor)

# Revisar factores únicos disponibles
unique(FACTORES$Factores_agravantes)

### --- F3 ---

# Mostrar posibles errores (valores fuera de rango esperado)
# Aspectos ambientales o fuentes de contaminación (F3)
valores_validos  <- c(0.06, 0.12, 0.18, 0.24, 0.30)

FACTORES %>%
  filter(Factores_agravantes == "F3", !(`% FA` %in% valores_validos )) %>%
  View()

# Realizar la corrección para una observación con %FA = 0.04
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F3" & `% FA` == 0.04 ~ "F2",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F3" & `% FA` == 0.04 ~ "El perjuicio económico causado",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F3 ---

FACTORES %>%
  filter(Factores_agravantes == "F3") %>%
  count(`% FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- F1 1.1 ---

# Mostrar posibles errores (valores fuera de rango esperado-se consideran daño potencial y real)
valores_validos  <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.9, 1.2, 1.5)

FACTORES %>%
  filter(Factores_agravantes == "F1 1.1", !(`% FA` %in% valores_validos )) %>%
  View()

#Se revisa el nombre específico de la categoría de reemplazo

FACTORES %>%
  count(Categoria_FA, sort = TRUE)

# Realizar la corrección para 4 observaciones en el caso con %FA = 0.12
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F1 1.1" & `% FA` == 0.12 ~ "F1 1.2",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F1 1.1" & `% FA` == 0.12 ~ "Grado de incidencia en la calidad del ambiente.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.1 ---

FACTORES %>%
  filter(Factores_agravantes == "F1 1.1") %>%
  count(`% FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- F1 1.2 ---

# Mostrar posibles errores (valores fuera de rango esperado)
valores_validos  <- c(0.06, 0.12, 0.18, 0.24, 0.18, 0.36, 0.54, 0.72)

FACTORES %>%
  filter(Factores_agravantes == "F1 1.2", !(`% FA` %in% valores_validos )) %>%
  View()

#Verificar el nombre de la categoría de reemplazo
FACTORES %>%
  count(Categoria_FA, sort = TRUE)

# Realizar la corrección para 7 casos donde  %FA = 0.1
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F1 1.2" & `% FA` == 0.1 ~ "F1 1.3",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F1 1.2" & `% FA` == 0.1 ~ "Según la extensión geográfica.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.2 ---

FACTORES %>%
  filter(Factores_agravantes == "F1 1.2") %>%
  count(`% FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- F1 1.3 ---

# Mostrar posibles errores (valores fuera de rango esperado)
valores_validos  <- c(0.1, 0.2, 0.3, 0.6)

FACTORES %>%
  filter(Factores_agravantes == "F1 1.3", !(`% FA` %in% valores_validos )) %>%
  View()

#Verificar el nombre de la categoría de reemplazo
FACTORES %>%
  filter(Factores_agravantes == "F1 1.4") %>%
  count(Categoria_FA, sort = TRUE)

# Realizar la corrección SOLO para el caso con %FA = 0.12 y 0.06
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F1 1.3" & `% FA` == 0.12 ~ "F1 1.4",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F1 1.3" & `% FA` == 0.12 ~ "Sobre la reversibilidad/recuperabilidad.",
      TRUE ~ Categoria_FA
    )
  )

#Verificar el nombre de la categoría de reemplazo
FACTORES %>%
  filter(Factores_agravantes == "F1 1.2") %>%
  count(Categoria_FA, sort = TRUE)

# Corrección para 0.06
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F1 1.3" & `% FA` == 0.06 ~ "F1 1.2",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F1 1.3" & `% FA` == 0.06 ~ "Grado de incidencia en la calidad del ambiente.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.3 ---

FACTORES %>%
  filter(Factores_agravantes == "F1 1.3") %>%
  count(`% FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- F1 1.4 ---

# Mostrar posibles errores (valores fuera de rango esperado)
valores_validos  <- c(0.06, 0.12, 0.18, 0.24, 0.36, 0.54, 0.72)

FACTORES %>%
  filter(Factores_agravantes == "F1 1.4", !(`% FA` %in% valores_validos )) %>%
  View()

# Realizar la corrección SOLO para el caso con %FA = 0.2 y 0.6
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Informes == "00490-2022-OEFA/DFAI-SSAG" & Factores_agravantes == "F1 1.4" & `% FA` == 0.2 ~ "F4",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Informes == "00490-2022-OEFA/DFAI-SSAG" & Factores_agravantes == "F1 1.4" & `% FA` == 0.2 ~ "Reincidencia en la comisión de la infracción",
      TRUE ~ Categoria_FA
    )
  )

FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Informes == "00252-2024-OEFA/DFAI-SSAG" & Factores_agravantes == "F1 1.4" & `% FA` == 0.2 ~ "F1 1.3",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Informes == "00252-2024-OEFA/DFAI-SSAG" & Factores_agravantes == "F1 1.4" & `% FA` == 0.2 ~ "Según la extensión geográfica",
      TRUE ~ Categoria_FA
    )
  )


FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F1 1.4" & `% FA` == 0.6 ~ "F1 1.7",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F1 1.4" & `% FA` == 0.6 ~ "Sobre la afectación a la salud de las personas",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.4 ---

FACTORES %>%
  filter(Factores_agravantes == "F1 1.4") %>%
  count(`% FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- F6 ---

# Mostrar posibles errores (valores fuera de rango esperado)
valores_validos <- c(0.3, 0.2, 0.1, -0.1)

FACTORES %>%
  filter(Factores_agravantes == "F6", !(`% FA` %in% valores_validos )) %>%
  View()

#Verificar el nombre de la categoría de reemplazo
FACTORES %>%
  filter(Factores_agravantes == "F5") %>%
  count(Categoria_FA, sort = TRUE)


# Realizar la corrección SOLO para el caso con %FA = -0.2
FACTORES <- FACTORES %>%
  mutate(
    Factores_agravantes = case_when(
      Factores_agravantes == "F6" & `% FA` == -0.2 ~ "F5",
      TRUE ~ Factores_agravantes
    ),
    Categoria_FA = case_when(
      Factores_agravantes == "F6" & `% FA` == -0.2 ~ 
        "Corrección de la conducta infractora",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F6 ---

FACTORES %>%
  filter(Factores_agravantes == "F6") %>%
  count(`% FA`, name = "COUNT") %>%
  adorn_totals("row")

### Análisis de los NA

# Comprobaciones 
sum(is.na(FACTORES$Categoria_FA))            # 972(no se tocan los NA)
sum(is.na(FACTORES$Factores_agravantes))     # 966 NA

# Filtrar los casos donde Categoria_FA es NA pero Factores_agravantes no lo es
diferencia <- FACTORES %>%
  filter(is.na(Categoria_FA) & !is.na(Factores_agravantes))
View(diferencia)   # Para inspeccionarlos 

#Se colocan las categorías correspondientes al Informe "01652-2022-OEFA/DFAI-SSAG"
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Informes == "01652-2022-OEFA/DFAI-SSAG" &
        Factores_agravantes == "F1" &
        is.na(Categoria_FA) ~ "Gravedad del daño al interés público y/o bien jurídico protegido",
      TRUE ~ Categoria_FA
    )
  )

#Se colocan las categorías correspondientes al Informe "01652-2022-OEFA/DFAI-SSAG"
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Informes == "01652-2022-OEFA/DFAI-SSAG" &
        Factores_agravantes == "F1 1.1" &
        is.na(Categoria_FA) ~ "El daño involucra uno o más de los siguientes Componentes Ambientales: a) Agua, b) Suelo, c) Aire, d) Flora y e) Fauna.",
      TRUE ~ Categoria_FA
    )
  )

#Se colocan las categorías correspondientes al Informe "01652-2022-OEFA/DFAI-SSAG"
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Informes == "01652-2022-OEFA/DFAI-SSAG" &
        Factores_agravantes == "F1 1.3" &
        is.na(Categoria_FA) ~ "Según la extensión geográfica.",
      TRUE ~ Categoria_FA
    )
  )

#Se colocan las categorías correspondientes al Informe "01652-2022-OEFA/DFAI-SSAG"
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Informes == "01652-2022-OEFA/DFAI-SSAG" &
        Factores_agravantes == "F1 1.4" &
        is.na(Categoria_FA) ~ "Sobre la reversibilidad/recuperabilidad.",
      TRUE ~ Categoria_FA
    )
  )

FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Informes == "01652-2022-OEFA/DFAI-SSAG" &
        Factores_agravantes == "F2" &
        is.na(Categoria_FA) ~ "El perjuicio económico causado",
      TRUE ~ Categoria_FA
    )
  )

FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Informes == "01652-2022-OEFA/DFAI-SSAG" &
        Factores_agravantes == "F3" &
        is.na(Categoria_FA) ~ "Aspectos ambientales o fuentes de contaminación",
      TRUE ~ Categoria_FA
    )
  )

rm(diferencia)


sum(is.na(FACTORES$Categoria_FA))            # sigue siendo 966 (no se tocan los NA)
sum(is.na(FACTORES$Factores_agravantes))     # Ahora si coinciden 

sum(FACTORES$`% FA` == 1, na.rm = TRUE)      
sum(FACTORES$`% FA` == 0, na.rm = TRUE)      #Los valores cero son 551, deberían ser 966

#Se está colocando que cuando la variable Factores_agravantes es NA, todo los valore de %FA son ceros
FACTORES <- FACTORES %>%
  mutate(
    `% FA` = case_when(
      is.na(Factores_agravantes) ~ 0,   # si Factores_agravantes es NA → poner 0
      TRUE ~ `% FA`                    # en cualquier otro caso, mantener el valor original
    )
  )

sum(FACTORES$`% FA` == 1, na.rm = TRUE)      # solo hay un caso que es igual a la unidad
sum(FACTORES$`% FA` == 0, na.rm = TRUE)      # Ahora coincide con los 966 valores
table(FACTORES$Factores_agravantes, useNA = "ifany")

table(FACTORES$Categoria_FA)

####Se homogeneiza las variables de las categorías Categoría_FA

FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Factores_agravantes == "F1 1.1" ~ "El daño involucra uno o más de los siguientes Componentes Ambientales: a) Agua, b) Suelo, c) Aire, d) Flora y e) Fauna.",
      TRUE ~ Categoria_FA   # mantener el valor original en los demás casos
    )
  )

FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Factores_agravantes == "F6" ~ "Adopción de las medidas necesarias para revertir las consecuencias de la conducta infractora",
      TRUE ~ Categoria_FA   # mantener el valor original en los demás casos
    )
  )

#Faltan revisar las que no coinciden con sus nombres y categorias

### --- Categoria_FA = F1 NO EXISTE EXISTE ERROR
FACTORES %>%
  filter(Factores_agravantes == "F1") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F1 1.1 NO EXISTE EXISTE ERROR
FACTORES %>%
  filter(Factores_agravantes == "F1 1.1") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F1 1.2  

# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Grado de incidencia en la calidad del ambiente.")

FACTORES %>%
  filter(Factores_agravantes == "F1 1.2", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Realizar la corrección 
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "El daño involucra uno o más de los siguientes Componentes Ambientales: a) Agua, b) Suelo, c) Aire, d) Flora y e) Fauna." & 
        Factores_agravantes == "F1 1.2" ~ "Grado de incidencia en la calidad del ambiente.",
      TRUE ~ Categoria_FA
    )
  )

FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Según la extensión geográfica." & 
        Factores_agravantes == "F1 1.2" ~ "Grado de incidencia en la calidad del ambiente.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.2 ---
FACTORES %>%
  filter(Factores_agravantes == "F1 1.2") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F1 1.3  
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Según la extensión geográfica.")

FACTORES %>%
  filter(Factores_agravantes == "F1 1.3", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Realizar la corrección 
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Grado de incidencia en la calidad del ambiente." & 
        Factores_agravantes == "F1 1.3" ~ "Según la extensión geográfica.",
      TRUE ~ Categoria_FA
    )
  )

FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Sobre la reversibilidad/recuperabilidad." & 
        Factores_agravantes == "F1 1.3" ~ "Según la extensión geográfica.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.3 ---
FACTORES %>%
  filter(Factores_agravantes == "F1 1.3") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F1 1.4 
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Sobre la reversibilidad/recuperabilidad.")

FACTORES %>%
  filter(Factores_agravantes == "F1 1.4", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Realizar la corrección 
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Según la extensión geográfica." & 
        Factores_agravantes == "F1 1.4" ~ "Sobre la reversibilidad/recuperabilidad.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.4 ---
FACTORES %>%
  filter(Factores_agravantes == "F1 1.4") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F1 1.5 
# No hay errores solo hay que hacer rename para estandarizar 
FACTORES %>%
  filter(Factores_agravantes == "F1 1.5") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

# Realizar la corrección 
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Afectacion sobre RRNN, area Natural protegida o zona de amortiguamiento" & 
        Factores_agravantes == "F1 1.5" ~ "Afectación sobre recursos naturales, área natural protegida o zona de amortiguamiento.",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.5 ---
FACTORES %>%
  filter(Factores_agravantes == "F1 1.5") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F1 1.7 
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Afectación a la salud de las personas" , "Afectacion a la salud de las personas")

FACTORES %>%
  filter(Factores_agravantes == "F1 1.7", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Estandarizo el nobre de  lsos factor  F1 1.7 
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Afectacion a la salud de las personas" & 
        Factores_agravantes == "F1 1.7" ~ "Afectación a la salud de las personas",
      TRUE ~ Categoria_FA
    )
  )

# Corrwecion de errores
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Sobre la reversibilidad/recuperabilidad." & 
        Factores_agravantes == "F1 1.7" ~ "Afectación a la salud de las personas",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F1 1.7 ---
FACTORES %>%
  filter(Factores_agravantes == "F1 1.7") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F2
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("EI perjuicio económico causado" , "El perjuicio económico causado")

FACTORES %>%
  filter(Factores_agravantes == "F2", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Estandarizo el nobre de  lsos factor  F2 
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "EI perjuicio económico causado" & 
        Factores_agravantes == "F2" ~ "El perjuicio económico causado",
      TRUE ~ Categoria_FA
    )
  )

# Corrwecion de errores
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Aspectos ambientales o fuentes de contaminación" & 
        Factores_agravantes == "F2" ~ "El perjuicio económico causado",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F2 ---
FACTORES %>%
  filter(Factores_agravantes == "F2") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F3
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Aspectos ambientales o fuentes de contaminación")

FACTORES %>%
  filter(Factores_agravantes == "F3", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Corrwecion de errores
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Adopción de las medidas necesarias para revertir las consecuencias de la conducta infractora" & 
        Factores_agravantes == "F3" ~ "Aspectos ambientales o fuentes de contaminación",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F3 ---
FACTORES %>%
  filter(Factores_agravantes == "F3") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F4
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Reincidencia en la comision de la infracción")

FACTORES %>%
  filter(Factores_agravantes == "F4", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# Corrwecion de errores
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Sobre la reversibilidad/recuperabilidad." & 
        Factores_agravantes == "F4" ~ "Reincidencia en la comision de la infracción",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F4 ---
FACTORES %>%
  filter(Factores_agravantes == "F4") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

### --- Categoria_FA = F5
# Mostrar posibles errores (valores fuera de rango esperado) 
valores_validos  <- c("Correccion de la conducta infractora", "Corrección de la conducta infractora")

FACTORES %>%
  filter(Factores_agravantes == "F5", !(`Categoria_FA` %in% valores_validos )) %>%
  View()

# STANDARIZACION DE NOMBRES
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Correccion de la conducta infractora" & 
        Factores_agravantes == "F5" ~ "Corrección de la conducta infractora",
      TRUE ~ Categoria_FA
    )
  )

# CORRECION DE NOMBRE
FACTORES <- FACTORES %>%
  mutate(
    Categoria_FA = case_when(
      Categoria_FA == "Adopción de las medidas necesarias para revertir las consecuencias de la conducta infractora" & 
        Factores_agravantes == "F5" ~ "Corrección de la conducta infractora",
      TRUE ~ Categoria_FA
    )
  )

### --- Verificar valores de F5 ---
FACTORES %>%
  filter(Factores_agravantes == "F5") %>%
  count(`Categoria_FA`, name = "COUNT") %>%
  adorn_totals("row")

FINAL <- FINAL %>%
  mutate(imputacion = paste0(Informes, "-", Num_Imputacion))


###################################
###### EXPORTANDO LAS BASES #######
###################################

# Exportamos las dos hojas a un solo archivo Excel
library(writexl)

write_xlsx(
  list(
    "Informes" = FINAL,
    "Factores" = FACTORES
  ),
  "basefinal.xlsx"
)

################################################################################
### PARTE 3: Cargar y actualizar base con sectores
################################################################################

# Importamos base auxiliar para corregir NANA en los sectores
sectores <- read_excel("INFORMES_GRADUACION_DCV (1).xlsx")

# Nos quedamos con filas únicas por combinación de claves
sectores_unicos <- sectores %>%
  select(Informes, Num_Imputacion, SectorEco2) %>%
  distinct()

# Actualizamos SectorEco en la base FINAL
FINAL <- FINAL %>%
  left_join(sectores_unicos, by = c("Informes", "Num_Imputacion")) %>%
  mutate(SectorEco = if_else(is.na(SectorEco) | SectorEco == "NANA",
                             SectorEco2, SectorEco)) %>%
  select(-SectorEco2)

# Volvemos a exportar Excel con la base FINAL actualizada
write_xlsx(
  list(
    "Informes" = FINAL,
    "Factores" = FACTORES
  ),
  "basefinal.xlsx"
)

# Liberamos objetos temporales
rm(sectores, sectores_unicos)

################################################################################
### COMPROBACIÓN DE LA CALIDAD DE LOS DATOS (Segunda fase)
################################################################################

# Número de registros con "NANA" en SectorEco
table(FINAL$SectorEco, useNA = "ifany")

# Número de informes distintos
n_distinct(FINAL$Informes)
n_distinct(FACTORES$Informes)







