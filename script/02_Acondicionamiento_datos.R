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

#Prueba de seleccion y renombrado de variables 
enaho <- enaho_raw %>%
  select(AÑO, MES, UBIGEO, gasto_alimentos, gasto_cultura) %>%
  rename(
    year = AÑO,
    month = MES,
    region = UBIGEO,
    alimentos = gasto_alimentos,
    cultura = gasto_cultura
  )
names(enaho_raw)
-----------------------------------------------------------------------------
# 1. SELECCIÓN, RENOMBRADO Y DIAGNÓSTICO
# ------------------------------------------------------------------------------
#Seleccion y renombre
enaho <- enaho_raw %>%
  select(
    año = AÑO,
    mes = MES,
    conglome = CONGLOME,
    vivienda = VIVIENDA,
    hogar    = HOGAR,
    ubigeo   = UBIGEO,
    dominio  = DOMINIO,
    estrato  = ESTRATO,
    nconglome = NCONGLOME,
    subconglome = SUB_CONGLOME,
    gasto_alimentos,
    gasto_cultura
  ) %>%
  rename(
    year     = año,
    month    = mes,
    region   = ubigeo,
    alimentos = gasto_alimentos,
    cultura   = gasto_cultura
  )

# Inspección inicial
dim(enaho)
names(enaho)
glimpse(enaho)
summary(enaho)

# 2. DIAGNÓSTICO DE NAs Y REPORTE-----------------------------------------------
# ------------------------------------------------------------------------------

# 2.1 Visualización Gráfica (naniar)
# Creamos un gráfico de barras que muestra la cantidad de NAs por variable
library(naniar)
grafico_nas <- gg_miss_var(enaho, show_pct = TRUE) +
  labs(
    title = "Porcentaje de Valores Perdidos (NAs) por Variable",
    subtitle = "Proyecto: Análisis de consumo en los hogares peruanos usando datos de la ENAHO (2025)",
    y = "% de Valores Perdidos",
    x = "Variables"
  ) +
  theme_minimal()

# Mostramos el gráfico en el panel de RStudio
print(grafico_nas)

# Exportamos el gráfico a nuestra carpeta de outputs
ggsave("outputs/Grafico_NAs_ENAHO.png", plot = grafico_nas, 
       width = 8, height = 6, bg = "white")

# 2.2 Reporte Tabular
# Calculamos el % de NAs por variable y lo guardamos en CSV
reporte_nas <- enaho %>%
  summarise(across(everything(), ~ round(sum(is.na(.)) / n() * 100, 2))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "porcentaje_na") %>%
  arrange(desc(porcentaje_na))

write_csv(reporte_nas, "outputs/Reporte_Datos_Perdidos_ENAHO.csv")

# 3. RECODIFICACIÓN DE CÓDIGOS ESPECIALES Y TIPOS DE DATOS ---------------------
# ------------------------------------------------------------------------------

# 3.1 Recodificación de códigos especiales (98, 99, 999)
# Según el diccionario ENAHO, estos valores representan "no sabe / no responde".
# Los convertimos a NA para evitar sesgos en cálculos posteriores.

enaho <- enaho %>%
  mutate(
    alimentos = na_if(alimentos, 98),
    alimentos = na_if(alimentos, 99),
    cultura   = na_if(cultura, 98),
    cultura   = na_if(cultura, 99)
  )

# Comentario:
# Los códigos 98/99 en los módulos de gasto representan "no sabe / no responde".
# Se convierten a NA antes de calcular promedios o totales de consumo.
#Aunque en los módulos gasto no aparecen valores peridos, documentamos esto como parte del diagnostico de NAs
#Si apareciera el código 99 ("no responde"), se convierte en NA. 
# 3.2 Ajuste de tipos de datos
# Revisamos los tipos con glimpse()
glimpse(enaho)

# Convertimos variables categóricas a factor
enaho <- enaho %>%
  mutate(
    region   = as.character(region),   # UBIGEO como texto para unir con catálogo
  )
# Comentario metodológico:
# UBIGEO se convierte a character para facilitar joins con catálogos oficiales.
# Los gastos se aseguran como numéricos para cálculos estadísticos. 

