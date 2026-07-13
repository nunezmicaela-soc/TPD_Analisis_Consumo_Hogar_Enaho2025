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


