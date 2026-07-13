#====================================================================
#Trabajo final . Taller de Procesamiento de Datos  
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Cargar los módulos, gestionar y hacer joins
#Módulos: Gastos del hogar en alimentos y bebidas (601); servicios a la vivienda (605); esparcimiento, diversión y servicios de cultura (606); bienes y servicios de cuidado personal (606D)
#Fecha: 12 de julio del 2026
#=====================================================================

#1. Carga de librerias----------------------------------------------------
library(tidyverse)
library(rio)
library(readr)
library(janitor)
library(arrow)
library(naniar)


#2. Definir ruta de datos-------------------------------------------
ruta_crudos <- "datos/crudos/"
ruta_procesados <- "datos/procesados/"

#3. Importar módulos------------------------------------

mod601 <- import("datos/crudos/Enaho01-2025-601.csv", encoding="Latin-1")
mod606 <- import("datos/crudos/Enaho01-2025-606.csv", encoding="Latin-1")
mod605 <- import("datos/crudos/Enaho01-2025-605.csv", encoding="Latin-1")
mod606D <- import("datos/crudos/Enaho01-2025-606D.csv", encoding="Latin-1")

#3. Union de bases--------------------------
keys_hogar <- c("AÑO", "MES", "CONGLOME", "VIVIENDA", "HOGAR","UBIGEO", "DOMINIO", "ESTRATO")

#Revisar los nombres de las columnas para identificar la variable de gasto
names(mod601)
names(mod606)
names(mod605)
names(mod606D)
glimpse(mod601)

#Revisar si la variable de gastos está en numérico o caracter 
str(mod601$P601C)
str(mod605$P605B)
str(mod606D$P606F)
str(mod606$P606B)

#Convertimos a numéricas las variables para consolidar la base de datos 
mod601 <- mod601 %>%
  mutate(P601C = as.numeric(P601C))

mod606 <- mod606 %>%
  mutate(P606B = as.numeric(P606B))

mod605 <- mod605 %>% 
  mutate(P605B = as.numeric(P605B))

mod606D <- mod606D %>% 
  mutate(P606F = as.numeric(P606F))

#Agrupar y resumir 
 
mod601 <- mod601 %>%
  group_by(across(all_of(keys_hogar))) %>%
  summarise(gasto_alimentos = sum(P601C, na.rm = TRUE), .groups = "drop")

mod606_hogar <- mod606 %>%
  group_by(across(all_of(keys_hogar))) %>%
  summarise(gasto_cultura = sum(P606B, na.rm = TRUE), .groups = "drop")

mod605_hogar <- mod605 %>%
  group_by(across(all_of(keys_hogar))) %>%
  summarise(gasto_vivienda = sum(P605B, na.rm = TRUE), .groups = "drop")

mod606D_hogar <- mod606D %>%
  group_by(across(all_of(keys_hogar))) %>%
  summarise(gasto_cuidados = sum(P606F, na.rm = TRUE), .groups = "drop")

enaho_2025 <- mod601_hogar %>%
  left_join(mod606_hogar, by = keys_hogar)

#4. Unimos las bases resumidas 
enaho_2025 <- mod601 %>%
  left_join(mod606_hogar,  by = keys_hogar) %>%
  left_join(mod605_hogar,  by = keys_hogar) %>%
  left_join(mod606D_hogar, by = keys_hogar)

#4. Exportamos base de datos creada------------------------
renv::snapshot() 
library(arrow)
write_parquet(enaho_2025, "datos/procesados/enaho_2025_230626.parquet")
enaho_2025 <- read_parquet("datos/procesados/enaho_2025_230626.parquet")


  
  
