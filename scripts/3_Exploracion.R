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

# 1. ESTADÍSTICOS DESCRIPTIVOS -------------------------------
# Gasto total del hogar
summary_gasto <- enaho %>%
  summarise(
    min = min(gasto_total, na.rm = TRUE),
    q25 = quantile(gasto_total, 0.25, na.rm = TRUE),
    mediana = median(gasto_total, na.rm = TRUE),
    promedio = mean(gasto_total, na.rm = TRUE),
    q75 = quantile(gasto_total, 0.75, na.rm = TRUE),
    max = max(gasto_total, na.rm = TRUE)
  )

# Ingreso laboral promedio
summary_ingreso <- enaho %>%
  summarise(
    min = min(ingreso_promedio, na.rm = TRUE),
    q25 = quantile(ingreso_promedio, 0.25, na.rm = TRUE),
    mediana = median(ingreso_promedio, na.rm = TRUE),
    promedio = mean(ingreso_promedio, na.rm = TRUE),
    q75 = quantile(ingreso_promedio, 0.75, na.rm = TRUE),
    max = max(ingreso_promedio, na.rm = TRUE)
)

#2. GRAFICOS UNIVARIADOS --------------------------------------------

# Histograma de gasto
grafico_gasto <- ggplot(enaho, aes(x = gasto_total)) +
  geom_histogram(fill = "#4A7C59", color = "white", bins = 50) +
  scale_x_continuous(labels = comma) +
  labs(title = "Distribución del gasto total del hogar",
       x = "Gasto mensual (S/)", y = "Frecuencia")
# Histograma de ingreso
ggplot(enaho, aes(x = ingreso_promedio)) +
  geom_histogram(fill = "#2E5B88", color = "white", bins = 50) +
  scale_x_continuous(labels = comma) +
  labs(title = "Distribución del ingreso laboral promedio",
       x = "Ingreso mensual (S/)", y = "Frecuencia")

# Crear carpeta de salida 
ruta_salida <- "outputs/outputs_exploracion"
if (!dir.exists(ruta_salida)) {
  dir.create(ruta_salida, recursive = TRUE)
}

# Exportar tablas descriptivas
write_csv(summary_gasto, file.path(ruta_salida, "Tabla_Estadisticos_Gasto.csv"))
write_csv(summary_ingreso, file.path(ruta_salida, "Tabla_Estadisticos_Ingreso.csv"))
