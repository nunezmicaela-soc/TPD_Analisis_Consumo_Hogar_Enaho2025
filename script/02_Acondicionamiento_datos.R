# ==============================================================================
#Trabajo final . Taller de Procesamiento de Datos  
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Acondicionar la base de datos consolidada (Tipado, selección, renombrado, tratamiento de NAs).
#Módulos: Gastos del hogar en alimentos y bebidas (601); servicios a la vivienda (605); esparcimiento, diversión y servicios de cultura (606); bienes y servicios de cuidado personal (606D)
#Fecha: 12 de julio del 2026
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. CONFIGURACIÓN
# ------------------------------------------------------------------------------

# Restaurar entorno del proyecto (renv)
renv::restore()

# Cargar librerías principales
library(tidyverse)
library(rio)       # import/export
library(arrow)     # parquet
library(janitor)   # limpieza de nombres
library(naniar)    # diagnóstico de valores perdidos

# ------------------------------------------------------------------------------
# 1. CARGA Y SELECCIÓN DE VARIABLES---------------------------------
# ------------------------------------------------------------------------------
# Leemos la base consolidada creada en el script pasado

enaho_raw <- read_parquet("datos/procesados/enaho_2025_uniongastos.parquet")

-----------------------------------------------------------------------------
# 2. SELECCIÓN, RENOMBRADO Y DIAGNÓSTICO
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
    gasto_alimentos,
    gasto_cultura,
    gasto_vivienda,
    gasto_cuidados
  ) %>%
  rename(
    year      = año,
    month     = mes,
    region    = ubigeo,
    alimentos = gasto_alimentos,
    cultura   = gasto_cultura,
    vivienda  = gasto_vivienda,
    cuidados_personales  = gasto_cuidados
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

# 4. EXPLORACIÓN DESCRIPTIVA DE GASTOS------------------------------------------
# ------------------------------------------------------------------------------

# 4.1 Estadísticas básicas
resumen_gastos <- enaho %>%
  summarise(
    promedio_alimentos = mean(alimentos, na.rm = TRUE),
    mediana_alimentos  = median(alimentos, na.rm = TRUE),
    promedio_cultura   = mean(cultura, na.rm = TRUE),
    mediana_cultura    = median(cultura, na.rm = TRUE)
  )
print(resumen_gastos)

# 4.2 Distribución de gastos
# Histograma de gasto en alimentos
ggplot(enaho, aes(x = alimentos)) +
  geom_histogram(binwidth = 50, fill = "steelblue", color = "white") +
  labs(
    title = "Distribución del gasto en alimentos",
    x = "Gasto en alimentos (S/.)",
    y = "Número de hogares"
  ) +
  theme_minimal()

# Histograma de gasto en cultura
ggplot(enaho, aes(x = cultura)) +
  geom_histogram(binwidth = 20, fill = "darkorange", color = "white") +
  labs(
    title = "Distribución del gasto en cultura",
    x = "Gasto en cultura (S/.)",
    y = "Número de hogares"
  ) +
  theme_minimal()

# 4.3 Comparación simple
# Relación entre gasto en alimentos y cultura
ggplot(enaho, aes(x = alimentos, y = cultura)) +
  geom_point(alpha = 0.4, color = "purple") +
  labs(
    title = "Relación entre gasto en alimentos y cultura",
    x = "Gasto en alimentos (S/.)",
    y = "Gasto en cultura (S/.)"
  ) +
  theme_minimal()

#Cambiar "ubigeo" por el nombre de los lugares, para ello importare la base de datos
library(readr)
# Debido a que la base tiene una sola columna separado por ";" read_delim (más explícito)
ubigeo_catalogo <- read_csv2("datos/crudos/ubigeo_inei_2025.csv")
ubigeo_catalogo <- read_delim("datos/crudos/ubigeo_inei_2025.csv", delim = ";")
glimpse(ubigeo_catalogo)

#La base consolidada tiene la columna de ubigeo con 5 digitos, mientras que el catalogo que baje 6 digitos
#Reducir el catalogo a 5 digitos 
ubigeo_catalogo <- ubigeo_catalogo %>%
  mutate(ubigeo5 = substr(ubigeo, 1, 5)) %>%   # recorta a 5 dígitos
  select(ubigeo5, departamento, provincia, distrito) %>%
  distinct()

#reducir a nivel de provincia
ubigeo_provincia <- ubigeo_catalogo %>%
  group_by(ubigeo5) %>%
  summarise(provincia = first(provincia)) %>%
  ungroup()

str(enaho$region)
head(ubigeo_catalogo$ubigeo5)

#hacer el join
enaho <- enaho %>%
  mutate(region = as.character(region)) %>%
  left_join(ubigeo_provincia, by = c("region" = "ubigeo5"))

#eliminar las columnas repetidas del join fallido 
enaho <- enaho %>%
  select(-ends_with(".x"), -ends_with(".y"))

#eliminar filas con NA en las variables geograficas 
enaho <- enaho %>%
  filter(!is.na(provincia), !is.na(distrito))

#Verificar que quedo limpio 
glimpse(enaho)
count(enaho, distrito)
count(enaho, provincia)

#Exportar 
library(dplyr)
library(arrow)
write_parquet(enaho, "datos/procesados/enaho_2025_provincias.parquet")
