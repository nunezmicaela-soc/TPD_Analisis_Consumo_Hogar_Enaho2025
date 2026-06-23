#=============================================
#Práctica Calificada 3: Datos de la ENAHO sobre "Esparcimiento, diversión y servicios de cultura" 
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
dir.create("script")

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

#4. Exportamos base de datos creada--------------------------------------
install.packages("arrow")
renv::snapshot()
