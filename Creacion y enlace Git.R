#=============================================
#Práctica Calificada 3: Datos de la ENAHO sobre "Actividad agropecuaria" 
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Crear sistema de carpetas y enlazar con GitHub
#Fecha: 21 junio del 2026
#==============================================================
#Creamos carpetas------------------------------------------
dir.create("datos")
dir.create("datos/crudos")
dir.create("datos/procesados")
dir.create("outputs")
dir.create("docs")

#Enlace con Git y Github 
install.packages("usethis")
usethis::use_git_config(user.name = "nunez.micaela-soc", user.email = "nunez.micaela@pucp.edu.pe")
usethis::use_git()

