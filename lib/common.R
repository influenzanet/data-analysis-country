###
# Common Script 
# Configure & setup environment, load common packages
###

options(ifn=list(autoconnect=FALSE, platform.path="config/", share.data="data/"))

## 
#  Default values for variables in config.R

# Name of the file to load containing platform definition (surveys, table mapping, ...)
PLATFORM_FILENAME = "default_platform"

library(duckdb)
library(DBI)
library(ifnBase)

#' Load configuration files and setup ifnBase package
load_config = function() {

  if(!file.exists("config")) {
     stop("Config directory is not in working directory are you runnning script in root of the directory as working directory")
  }
  
  if(!file.exists("config")) {
    stop("Config directory is not in working directory are you runnning script in root of the directory as working directory")
  }
   
  config_file = file.path("config", "config.R")
  
  if(!file.exists(config_file)) {
    stop("file config.R found in config/ directory, did you configure the project")
  }

  source(config_file, local=.GlobalEnv)
  
  if(exists("DB_DSN")) {
    driver = NULL
    dsn = NULL
    if(rlang::is_scalar_character(DB_DSN)) {
      driver= "duckdb"
      dsn = list(dbdir=DB_DSN)
    }
    if(is.list(DB_DSN)) {
      driver = DB_DSN$driver
      n = names(DB_DSN)
      n = n[ n != "driver"]
      dsn = DB_DSN[ n ]
    }
    if(is.null(driver)) {
      stop("DB_DSN must contains `driver` entry with db driver name")
    }
    message("Found DB driver=", driver, " dsn=", dsn)
    share.option(db_driver=driver, db_dsn=dsn)
    dbConnect()
  } else {
    warning("`DB_DSN` has not been found, no database will be available")
  } 
  
  share.option(platform=PLATFORM_FILENAME)
  
  invisible()
}

load_config()
ifnBase::load_platform()