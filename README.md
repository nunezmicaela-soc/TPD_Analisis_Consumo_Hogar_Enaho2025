# Analisis de módulos de gasto del hogar en alimentacion y cultura para PC3
## Descripción del proyecto 
El objetivo es practicar la importación, transformación y unión de bases de datos en R a partir de los microdatos de la **Encuesta Nacional de Hogares (ENAHO) 2025**.

## Módulos utilizados
- **601 – Gastos en alimentos y bebidas del hogar**  
  Recoge información sobre productos adquiridos, frecuencia, lugar de compra y monto gastado.
- **606 – Esparcimiento, diversión y servicios de cultura**  
  Incluye gastos en actividades recreativas, cultura, entretenimiento y servicios relacionados.

## Pasos realizados
1. **Importación de datos** en formato `.sav` usando `rio`.
2. **Conversión de variables de monto** a tipo numérico (`as.numeric`).
3. **Agregación por hogar**: se resumieron los gastos de cada módulo a nivel de hogar usando `group_by()` y `summarise()`.
4. **Unión de bases**: se integraron los módulos 601 y 606 mediante las llaves del hogar (`AÑO, MES, CONGLOME, VIVIENDA, HOGAR, UBIGEO, DOMINIO, ESTRATO, NCONGLOME, SUB_CONGLOME`).
5. **Exportación final** en formato Parquet (`write_parquet`) para un almacenamiento eficiente.

## Resultado
Se obtuvo una base consolidada (`enaho_2025.parquet`) con una fila por hogar, que contiene:
- Gasto total en alimentos y bebidas.
- Gasto total en cultura y esparcimiento.


# Analisis de módulos de gasto del hogar en alimentacion y cultura para PC4

Este proyecto corresponde al curso **Taller de Procesamiento de Datos** (Sociología, PUCP).  
El objetivo es **acondicionar** los microdatos de la **ENAHO 2025**, integrando los módulos de gasto en alimentos (601) y cultura/esparcimiento (606) para obtener una base a nivel de hogar.  
Se busca explorar patrones de consumo en los hogares peruanos.

## Estructura de carpetas
- `datos/crudos/` → Archivos originales descargados de ENAHO  
- `datos/procesados/` → Archivos transformados y exportados (ej. parquet)  
- `scripts/` → Código en R para importación, limpieza, unión y exportación  
- `docs/` → Documentación y cuestionarios de los módulos  
- `outputs/` → Resultados finales (tablas, gráficos)

## Flujo de trabajo
1. Importación de módulos 601 y 606 en R.  
2. Conversión de variables de monto a numéricas.  
3. Agregación de gastos por hogar.  
4. Unión de módulos mediante llaves del hogar.  
5. Exportación final en formato Parquet.  

## Resultado
Se obtuvo una base consolidada (`enaho_2025.parquet`) con una fila por hogar que contiene:  
- Gasto total en alimentos y bebidas.  
- Gasto total en cultura y esparcimiento.  
