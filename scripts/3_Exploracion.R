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


#1. Construir las variables: gasto total e ingreso total
library(tidyverse)

# a. crear gasto total 
enaho <- enaho %>%
  mutate(
    gasto_total = rowSums(
      select(., alimentos, cultura, vivienda_servicios, cuidados_personales),
      na.rm = TRUE
    )
  )
#exploracion del gasto total 
# Estadísticos descriptivos
summary_gasto <- enaho %>%
  summarise(
    min = min(gasto_total, na.rm = TRUE),
    q25 = quantile(gasto_total, 0.25, na.rm = TRUE),
    mediana = median(gasto_total, na.rm = TRUE),
    promedio = mean(gasto_total, na.rm = TRUE),
    q75 = quantile(gasto_total, 0.75, na.rm = TRUE),
    max = max(gasto_total, na.rm = TRUE)
  )

# Histograma
grafico_gasto <- ggplot(enaho %>% filter(gasto_total < 5000),
                        aes(x = gasto_total)) +
  geom_histogram(fill = "#4A7C59", color = "white", bins = 50) +
  scale_x_continuous(labels = comma) +
  labs(title = "Distribución del gasto total del hogar (<5000 S/)",
       x = "Gasto mensual (S/)", y = "Frecuencia")


#exportar 
ruta_salida <- "outputs/outputs_exploracion"
if (!dir.exists(ruta_salida)) {
  dir.create(ruta_salida, recursive = TRUE)
}

write_csv(summary_gasto, file.path(ruta_salida, "Tabla_Estadisticos_Gasto.csv"))

ggsave(file.path(ruta_salida, "Grafico_Histograma_Gasto.png"),
       plot = grafico_gasto, width = 8, height = 5, bg = "white")

#b.Crear variable de ingreso total 
library(tidyverse)
ingresos_tratados <- import("datos/procesados/enaho_2025_ingresos_tratados.csv")

#Crear ingreso_persona (suma de las tres fuentes)
ingresos_tratados <- ingresos_tratados %>%
  mutate(
    ingreso_persona = ingreso_dep + ingreso_indep_dinero + ingreso_indep_especie
  )
#Agregar a nivel hogar
ingreso_hogar <- ingresos_tratados %>%
  group_by(CONGLOME, VIVIENDA, HOGAR) %>%
  summarise(
    ingreso_total = sum(ingreso_persona, na.rm = TRUE),
    .groups = "drop"
  )
#Exportar ingreso total por hogar
write_csv(ingreso_hogar, "datos/procesados/enaho_2025_ingreso_total.csv")

#2. CONTRASTE GASTO E INGRESO 
library(tidyverse)
library(scales)

# Cargar ingreso total por hogar
ingreso_hogar <- read_csv("datos/procesados/enaho_2025_ingreso_total.csv")

# Consolidar gasto e ingreso por hogar
contraste <- enaho %>%
  select(CONGLOME, VIVIENDA, HOGAR, gasto_total) %>%
  inner_join(ingreso_hogar, by = c("CONGLOME","VIVIENDA","HOGAR"))

glimpse(contraste)
nrow(contraste)

#graficar 
grafico_ingreso <- ggplot(ingreso_hogar %>% filter(ingreso_total > 0, ingreso_total < 20000),
                          aes(x = ingreso_total)) +
  geom_histogram(fill = "#2E5B88", color = "white", bins = 50) +
  scale_x_continuous(labels = comma) +
  labs(title = "Distribución del ingreso total del hogar (<20000 S/)",
       x = "Ingreso mensual (S/)", y = "Frecuencia")

ggsave(file.path(ruta_salida, "Grafico_Histograma_Ingreso.png"),
       plot = grafico_ingreso, width = 8, height = 5, bg = "white")

