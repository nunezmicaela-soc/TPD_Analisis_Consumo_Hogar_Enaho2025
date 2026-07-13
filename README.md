# Procesamiento de datos ENAHO 2025: patrones de gasto en hogares
## Autor: Micaela Núñez Cordero
## Encuesta: ENAHO 2025 - INEI
## Módulos utilizados: 601 (Alimentos), 606 (Cultura y esparcimiento), 605 (Servicios a la vivienda), 606D (Cuidados personales)
## Unidad de análisis: Hogar
-------
## Descripción del proyecto 

## Módulos utilizados
- **601 – Gastos en alimentos y bebidas del hogar**  
  Recoge información sobre productos adquiridos, frecuencia, lugar de compra y monto gastado.
- **606 – Esparcimiento, diversión y servicios de cultura**  
  Incluye gastos en actividades recreativas, cultura, entretenimiento y servicios relacionados.
------
# README - Procesamiento reproducible de módulos ENAHO 2025: consolidación de gastos en hogares
---
## 1. EXTRAER
- Se descargaron los microdatos de la ENAHO 2025 desde el portal de INEI.
- Se seleccionaron los módulos 601, 606, 605 y 606D por su relevancia en el análisis de gasto de los hogares.
- Los archivos originales se almacenaron en `01_datos/originales/`.

---

## 2. GESTIONAR
- Se definió la estructura del proyecto con carpetas para datos, scripts y outputs.
- Se importaron los módulos en R y se homogenizaron las llaves de unión (`año, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato`).
- Se convirtieron las variables de gasto a formato numérico para asegurar consistencia.
- Se agruparon los datos por hogar y se resumieron los gastos en cuatro categorías: alimentos, cultura, servicios de vivienda y cuidados personales.
- Se exportó la base consolidada en formato Parquet a `01_datos/procesados/enaho_2025_union.parquet`.

---

## 3. ACONDICIONAR
*(pendiente de desarrollo en el examen final: diagnóstico de NAs, unión con UBIGEO, limpieza de duplicados)*

---

