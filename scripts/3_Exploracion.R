# ============================================================
# Proyecto: Análisis de gasto vs ingreso en hogares ENAHO 2025
# Script: Exploración básica
# Autor: Micaela
# Fecha: 13-07-2026
# Objetivo: Explorar la distribución de gasto e ingreso y contrastar
# ============================================================

rm(list = ls())
library(tidyverse)
library(arrow)
library(scales)

# 0. CARGA DE DATOS ------------------------------------------
enaho <- read_parquet("datos/procesados/enaho_2025_provincias.parquet")

#Limpiar base de datos 

#Identificar columnas de provincia
prov_cols <- names(enaho)[grepl("^provincia", names(enaho))]
print(prov_cols)  # para verificar cuáles están

# Revisar cuál columna de provincia tiene menos NAs
summary(enaho$provincia.x)
summary(enaho$provincia.y)
summary(enaho$provincia.x.x)
summary(enaho$provincia.y.y)

# Contar NAs en cada columna de provincia
colSums(is.na(enaho[, c("provincia.x", "provincia.y", "provincia.x.x", "provincia.y.y")]))

# Usar la columna completa de provincia
enaho <- enaho %>%
  transmute(
    region6,
    departamento,
    provincia = provincia.y.y,  # única columna completa
    distrito,
    gasto_total,
    ingreso_promedio,
    across(everything())
  ) %>%
  distinct()




