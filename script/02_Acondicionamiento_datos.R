# ==============================================================================
# Proyecto: Análisis de consumo en los hogares peruanos con datos de la ENAHO
# Script: Acondicionamiento 
# Autor: Micaela Nuñez 
# Fecha: 05-07-2026
# Objetivo: Acondicionar la base de datos consolidada (Tipado, Selección, 
#           Renombrado, Tratamiento de NAs).
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN
# ------------------------------------------------------------------------------

# Restaurar entorno del proyecto (renv)
renv::restore()

#Instalar paquetes 
install.packages("rio")
install.packages ("tidyverse")
install.packages("arrow")
install.packages("janitor")
install.packages("pkgbuild")
install.packages("Rcpp")
install.packages("naniar")

# Cargar librerías principales
library(tidyverse)
library(rio)       # import/export
library(arrow)     # parquet
library(janitor)   # limpieza de nombres
library(naniar)    # diagnóstico de valores perdidos


# Verificar que Rtools está disponible 
pkgbuild::has_build_tools(debug = TRUE)

# Actualizar snapshot de renv cuando ya todo está instalado
renv::snapshot()

# ------------------------------------------------------------------------------
# 1. CARGA, SELECCIÓN, RENOMBRADO Y DIAGNÓSTICO---------------------------------
# ------------------------------------------------------------------------------
# Leemos la base consolidada de la PC3
library(tidyverse)
library(arrow)
enaho_raw <- read_parquet("datos/procesados/enaho_2025_230626.parquet")

#Seleccion y renombrado de variables 
enaho <- enaho_raw %>%
  select(AÑO, MES, UBIGEO, gasto_alimentos, gasto_cultura) %>%
  rename(
    year = AÑO,
    month = MES,
    region = UBIGEO,
    alimentos = gasto_alimentos,
    cultura = gasto_cultura
  )



