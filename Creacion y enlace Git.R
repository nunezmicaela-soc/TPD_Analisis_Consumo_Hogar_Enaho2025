#=============================================
#Trabajo final . Taller de Procesamiento de Datos  
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Crear sistema de carpetas y enlazar con GitHub
#Módulos: Gastos del hogar en alimentos y bebidas (600); servicios a la vivienda (605); esparcimiento, diversión y servicios de cultura (606); bienes y servicios de cuidado personal (606D)
#Fecha: 12 de julio del 2026
#==============================================================
#Creamos carpetas------------------------------------------
dir.create("datos")
dir.create("datos/crudos")
dir.create("datos/procesados")
dir.create("outputs")
dir.create("docs")
dir.create("scripts")

#Enlace con Git y Github 
install.packages("usethis")
install.packages("gitcreds")

library(usethis)
library(gitcreds)

usethis::use_git_config(user.name = "nunez.micaela-soc", user.email = "nunez.micaela@pucp.edu.pe")
usethis::use_git()

# Verfificar token anterior esta activo y guardado
gitcreds::gitcreds_get()




