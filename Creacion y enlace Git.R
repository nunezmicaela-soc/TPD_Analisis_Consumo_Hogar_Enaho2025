#=============================================
#Trabajo final . Taller de Procesamiento de Datos  
#Autora: Micaela Nuñez Cordero
#Objetivo de script: Crear sistema de carpetas y enlazar con GitHub
# Módulos: Gastos del hogar en alimentos y bebidas (600); servicios a la vivienda (605); esparcimiento, diversión y servicios de cultura (606); bienes y servicios de cuidado personal (606D)
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
usethis::use_git_config(user.name = "nunez.micaela-soc", user.email = "nunez.micaela@pucp.edu.pe")
usethis::use_git()
install.packages("gitcreds")
usethis::create_github_token()
gitcreds::gitcreds_set()
install.packages("gh")
usethis::use_github()
install.packages("usethis")
install.packages("gh")
install.packages("gitcreds")
usethis::use_github()

remove.packages("usethis")
remove.packages("gh")
remove.packages("gitcreds")

install.packages("usethis")
install.packages("gh")
install.packages("gitcreds")

usethis::use_git()
usethis::use_github()
usethis::create_github_token()
gitcreds::gitcreds_set()
gitcreds::gitcreds_get()
usethis::use_github()
usethis::use_git_remote("origin", url = NULL, overwrite = TRUE)`
usethis::use_github()

usethis::use_git_config(user.name = "nunez.micaela-soc", user.email = "nunez.micaela@pucp.edu.pe")
usethis::use_git()
usethis::use_github()

git remote add origin https://github.com/nunezmicaela-soc/PC3_TPD.git
git branch -M main
git push -u origin main
usethis::create_github_token()
gitcreds::gitcreds_set()

