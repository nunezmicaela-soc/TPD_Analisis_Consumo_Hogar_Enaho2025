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

# 3. DIAGNÓSTICO DE NAs --------------------------------------------------------
grafico_nas500 <- gg_miss_var(ingresos_sel, show_pct = TRUE) +
  labs(title = "Porcentaje de NAs en módulo 500",
       subtitle = "Ingresos laborales - ENAHO 2025") +
  theme_minimal()

print(grafico_nas500)

ggsave("outputs/Grafico_NAs_Mod500.png", plot = grafico_nas)

reporte_nas500 <- ingresos_sel %>%
  summarise(across(everything(), ~ round(sum(is.na(.)) / n() * 100, 2))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "porcentaje_na")

write_csv(reporte_nas500, "outputs/Reporte_NAs_Mod500.csv")

# 4. TRATAMIENTO DE NAs --------------------------------------------------------
ingresos_tratados <- ingresos_sel %>%
  mutate(
    ingreso_dep            = na_if(ingreso_dep, 999999),
    ingreso_indep_dinero   = na_if(ingreso_indep_dinero, 999999),
    ingreso_indep_especie  = na_if(ingreso_indep_especie, 999999)
  ) %>%
  mutate(
    ingreso_dep            = replace_na(ingreso_dep, median(ingreso_dep, na.rm = TRUE)),
    ingreso_indep_dinero   = replace_na(ingreso_indep_dinero, median(ingreso_indep_dinero, na.rm = TRUE)),
    ingreso_indep_especie  = replace_na(ingreso_indep_especie, median(ingreso_indep_especie, na.rm = TRUE))
  )
