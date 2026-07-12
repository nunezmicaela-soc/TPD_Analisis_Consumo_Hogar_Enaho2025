#====================================================================
#Trabajo final . Taller de Procesamiento de Datos  
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Cargar los módulos, gestionar y hacer joins
#Módulos: Gastos del hogar en alimentos y bebidas (600); servicios a la vivienda (605); esparcimiento, diversión y servicios de cultura (606); bienes y servicios de cuidado personal (606D)
#Fecha: 12 de julio del 2026
#=====================================================================

#1. Carga de librerias----------------------------------------------------
library(tidyverse)
library(rio)
library(readr)
library(janitor)
library(arrow)
library(naniar)


#2. Definir ruta de datos 
library(rio)
mod601 <- import("datos/crudos/Enaho01-2025-601.csv", encoding="Latin-1")
mod606 <- import("datos/crudos/Enaho01-2025-606.csv", encoding="Latin-1")

#3. Union de bases--------------------------
keys_hogar <- c("AÑO", "MES", "CONGLOME", "VIVIENDA", "HOGAR","UBIGEO", "DOMINIO", "ESTRATO", "NCONGLOME", "SUB_CONGLOME")
names(mod601)
names(mod606)

str(mod601$P601C)

mod601 <- mod601 %>%
  mutate(P601C = as.numeric(P601C))
mod606 <- mod606 %>%
  mutate(P606B = as.numeric(P606B))

mod601_hogar <- mod601 %>%
  mutate(P601C = as.numeric(P601C)) %>%
  group_by(across(all_of(keys_hogar))) %>%
  summarise(gasto_alimentos = sum(P601C, na.rm = TRUE), .groups = "drop")

mod606_hogar <- mod606 %>%
  mutate(P606B = as.numeric(P606B)) %>%
  group_by(across(all_of(keys_hogar))) %>%
  summarise(gasto_cultura = sum(P606B, na.rm = TRUE), .groups = "drop")

enaho_2025 <- mod601_hogar %>%
  left_join(mod606_hogar, by = keys_hogar)

#4. Exportamos base de datos creada------------------------
renv::snapshot() 
library(arrow)
write_parquet(enaho_2025, "datos/procesados/enaho_2025_230626.parquet")
enaho_2025 <- read_parquet("datos/procesados/enaho_2025_230626.parquet")


  
  
