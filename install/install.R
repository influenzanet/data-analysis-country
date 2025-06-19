## This script can be run to install the necessary packages

if(is(packageVersion("remotes"), "try-error")) {
  install.packages("remotes")
}

r = remotes::dev_package_deps(".")

remotes::install_deps(".", upgrade = "never")
