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
Los módulos de gasto tienen distintos períodos de referencia (15 días, mensual, gasto puntual). Para efectos de consolidación se normalizó alimentos a gasto mensual aproximado (×2), mientras que servicios y cultura se mantuvieron como mensuales. Los cuidados personales se documentan como gasto puntual. 
- Módulo 601 (alimentos y bebidas): gasto en los últimos 15 días.
- Módulo 605 (servicios de vivienda): gasto mensual fijo.
- Módulo 606 (cultura/esparcimiento): gasto en el último mes.
- Módulo 606D (cuidados personales): gasto por compra/servicio puntual.
- 
## 3. ACONDICIONAR
1. Acondicionamiento de datos ENAHO 2025
- Tratamiento de valores faltantes (NAs) – Módulo 500
- Se recodificaron los valores 999999 como NA (códigos de no sabe/no responde).
- Se generó un reporte tabular y gráfico del porcentaje de NAs por variable (ingreso_dep, ingreso_indep_dinero, ingreso_indep_especie).
- Se aplicó imputación exploratoria con la mediana para reemplazar NAs en las variables de ingreso, manteniendo la distribución central y reduciendo el impacto de valores extremos.

2. Integración de UBIGEO
- Se importó el catálogo oficial de UBIGEO (INEI 2025) en formato .csv con delimitador ;.
- Se mantuvo el catálogo en su formato original de 6 dígitos.
- La columna region de ENAHO se normalizó a 6 dígitos con ceros a la izquierda (region6).
- Se realizó un left_join directo con el catálogo, incorporando departamento, provincia y distrito.
- Se eliminó el recorte previo a 5 dígitos, que generaba más de 1,200 códigos sin match.
- Se verificó la integración con anti_join, asegurando que los códigos se mapearan correctamente.

3. Exportación de base consolidada
- La columna region6 se mantiene como clave geográfica normalizada a 6 dígitos.
- Se incorporaron los nombres de departamento, provincia y distrito desde el catálogo INEI.
- Se exportó la base consolidada en formato Parquet

4. Nota metodológica
- La integración de UBIGEO permite trabajar tanto con claves geográficas como con nombres de lugares, facilitando análisis comparativos por provincia y distrito.
  
## EXPLORAR 
1. Construcción de variables
- Gasto total: se creó sumando las partidas de alimentos, cultura, vivienda/servicios y cuidados personales.
- Ingreso total: se construyó a partir del módulo 500, sumando ingresos dependientes, independientes en dinero e independientes en especie, y luego agregando a nivel hogar.

2. Exploración del gasto total
- Se calcularon estadísticos descriptivos: mínimo, cuartiles, mediana, promedio y máximo.
- Se generó un histograma de la distribución del gasto total (con corte en 5000 S/ para evitar valores extremos).

3. Outputs exportados:
- Tabla_Estadisticos_Gasto.csv
- Grafico_Histograma_Gasto.png

4. Exploración del ingreso total
- Se calcularon estadísticos descriptivos: mínimo, cuartiles, mediana, promedio y máximo.
- Se generó un histograma de la distribución del ingreso total (con corte en 20000 S/ para evitar valores extremos).
- no se exporto outputs 

5. Limitaciones encontradas
- No se logró avanzar hacia el contraste entre gasto e ingreso por errores en la integración de las bases.
- Los intentos de graficar el contraste resultaron en errores de depuración (browser) y gráficos vacíos.
- No se pudo construir la tabla de quintiles ni realizar el análisis comparativo.
- Tampoco se alcanzó a integrar la información de UBIGEO por problemas de formato y coincidencia de códigos.

---

