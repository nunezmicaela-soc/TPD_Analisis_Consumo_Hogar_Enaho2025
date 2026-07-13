# ==============================================================================
#Trabajo final . Taller de Procesamiento de Datos  
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Acondicionar la base de datos consolidada (Tipado, selección, renombrado, tratamiento de NAs).
#Módulos: Gastos del hogar en alimentos y bebidas (601); servicios a la vivienda (605); esparcimiento, diversión y servicios de cultura (606); bienes y servicios de cuidado personal (606D)
#Fecha: 12 de julio del 2026
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN
# ------------------------------------------------------------------------------

# Restaurar entorno del proyecto (renv)
renv::restore()

# Cargar librerías principales
library(tidyverse)
library(rio)       # import/export
library(arrow)     # parquet
library(janitor)   # limpieza de nombres
library(naniar)    # diagnóstico de valores perdidos

# ------------------------------------------------------------------------------
# 1. CARGA Y SELECCIÓN DE VARIABLES---------------------------------
# ------------------------------------------------------------------------------
# Leemos la base consolidada creada en el script pasado

enaho_raw <- read_parquet("datos/procesados/enaho_2025_uniongastos.parquet")

-----------------------------------------------------------------------------
# 2. SELECCIÓN, RENOMBRADO Y DIAGNÓSTICO
# ------------------------------------------------------------------------------
#Seleccion y renombre
enaho <- enaho_raw %>%
  select(
    año = AÑO,
    mes = MES,
    conglome = CONGLOME,
    vivienda = VIVIENDA,
    hogar    = HOGAR,
    ubigeo   = UBIGEO,
    dominio  = DOMINIO,
    estrato  = ESTRATO,
    gasto_alimentos,
    gasto_cultura,
    gasto_vivienda,
    gasto_cuidados
  ) %>%
  rename(
    year      = año,
    month     = mes,
    region    = ubigeo,
    alimentos = gasto_alimentos,
    cultura   = gasto_cultura,
    vivienda_servicios  = gasto_vivienda,
    cuidados_personales  = gasto_cuidados
  )

# Inspección inicial
dim(enaho)
names(enaho)
glimpse(enaho)
summary(enaho)

# 3. DIAGNÓSTICO DE NAs Y REPORTE-----------------------------------------------
# ------------------------------------------------------------------------------

# 3.1 Visualización gráfica de NAs por variable
# Creamos un gráfico de barras que muestra la cantidad de NAs por variable
grafico_nas <- gg_miss_var(enaho, show_pct = TRUE) +
  labs(
    title = "Porcentaje de Valores Perdidos (NAs) por Variable",
    subtitle = "ENAHO 2025 - Proyecto de procesamiento",
    y = "% de Valores Perdidos",
    x = "Variables"
  ) +
  theme_minimal()

# Mostramos el gráfico en el panel de RStudio-----------------------------------
print(grafico_nas)

# Exportamos el gráfico a nuestra carpeta de outputs
ggsave("03_outputs/Grafico_NAs_ENAHO.png", plot = grafico_nas,
       width = 8, height = 6, bg = "white")
  theme_minimal()

# 3.2 Reporte Tabular
# Calculamos el % de NAs por variable y lo guardamos en CSV---------------------
reporte_nas <- enaho %>%
  summarise(across(everything(), ~ round(sum(is.na(.)) / n() * 100, 2))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "porcentaje_na") %>%
  arrange(desc(porcentaje_na))

write_csv(reporte_nas, "outputs/Reporte_Datos_Perdidos_ENAHO.csv")

#3.3 Importamos base de datos de empleo e ingreso módulo 500
#Carga de base de datos
mod500 <- import ("datos/crudos/Enaho01a-2025-500.csv")

# Seleccionamos ingreso principal y llaves de persona
ingresos_sel <- mod500 %>%
  select(AÑO, MES, CONGLOME, VIVIENDA, HOGAR, CODPERSO,
         ingreso_prin = P524A1)

#Cambiar "ubigeo" por el nombre de los lugares, para ello importare la base de datos
library(readr)
# Debido a que la base tiene una sola columna separado por ";" read_delim (más explícito)
ubigeo_catalogo <- read_csv2("datos/crudos/ubigeo_inei_2025.csv")
ubigeo_catalogo <- read_delim("datos/crudos/ubigeo_inei_2025.csv", delim = ";")
glimpse(ubigeo_catalogo)

#La base consolidada tiene la columna de ubigeo con 5 digitos, mientras que el catalogo que baje 6 digitos
#Reducir el catalogo a 5 digitos 
ubigeo_catalogo <- ubigeo_catalogo %>%
  mutate(ubigeo5 = substr(ubigeo, 1, 5)) %>%   # recorta a 5 dígitos
  select(ubigeo5, departamento, provincia, distrito) %>%
  distinct()

#reducir a nivel de provincia
ubigeo_provincia <- ubigeo_catalogo %>%
  group_by(ubigeo5) %>%
  summarise(provincia = first(provincia)) %>%
  ungroup()

str(enaho$region)
head(ubigeo_catalogo$ubigeo5)

#hacer el join
enaho <- enaho %>%
  mutate(region = as.character(region)) %>%
  left_join(ubigeo_provincia, by = c("region" = "ubigeo5"))

#eliminar las columnas repetidas del join fallido 
enaho <- enaho %>%
  select(-ends_with(".x"), -ends_with(".y"))

#eliminar filas con NA en las variables geograficas 
enaho <- enaho %>%
  filter(!is.na(provincia), !is.na(distrito))

#Verificar que quedo limpio 
glimpse(enaho)
count(enaho, distrito)
count(enaho, provincia)

#Exportar 
library(dplyr)
library(arrow)
write_parquet(enaho, "datos/procesados/enaho_2025_provincias.parquet")
