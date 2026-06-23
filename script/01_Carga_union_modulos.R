#====================================================================
#Proyecto: Análisis de Esparcimiento, diversión y servicios de cultura usando datos de la Enaho para PC3
#Script: Cargar los módulos y hacer los joins 
#Autor: Micaela Nuñez 
#Fecha: 22-06-26
#=====================================================================

#1. Carga de librerias----------------------------------------------------
install.packages("tidyverse")
library(tidyverse)
install.packages("rio")
library(rio)
library(readr)
install.packages("janitor")
library(janitor)
install.packages("renv")

library(readr)
renv::init()
renv::snapshot()

#2. Importar datos
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


  
  
