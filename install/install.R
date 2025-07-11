## This script can be run to install the necessary packages

v = try(packageVersion("remotes"), silent=TRUE)
if(inherits(v, "try-error")) {
  install.packages("remotes")
}

r = remotes::dev_package_deps(".")

remotes::install_deps(".", upgrade = "never")
