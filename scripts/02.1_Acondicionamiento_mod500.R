# Objetivo: Diagnóstico y tratamiento de NAs en ingresos (módulo 500)
# Unidad de análisis: persona (para ingresos), contraste posterior con gasto por hogar
# Fecha: 13-07-2026
# ==============================================================================

# 0. CONFIGURACIÓN -------------------------------------------------------------
library(tidyverse)
library(readr)
library(naniar)

# 1. CARGA DE BASE -------------------------------------------------------------
# Importamos el módulo 500 (empleo e ingresos)
mod500 <- import("datos/crudos/Enaho01a-2025-500.csv", encoding="Latin-1")

# 2. SELECCIÓN DE VARIABLES CLAVE ---------------------------------------------
names(mod500)

ingresos_sel <- mod500 %>%
  select(
    AÑO, MES, CONGLOME, VIVIENDA, HOGAR, CODPERSO,
    ingreso_dep = P524A1,   # ingreso principal dependientes
    ingreso_indep_dinero = P530A,  # ganancia neta independientes (dinero)
    ingreso_indep_especie = P530B  # ganancia neta independientes (especie)
  )
glimpse(ingresos_sel)
