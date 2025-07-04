###
# Common Script 
# Configure & setup environment, load common packages
###

project.root = workspace::find_workspace()

options(ifn=list(
    autoconnect=FALSE, 
    platform.path=paste0(project.root, "/config/"), 
    share.data=paste0(project.root, "/data/"), # where to find data files using share.data.path() function
    share.lib.path=paste0(project.root, "/lib/") # Where to find library scripts using share.lib() function
  )
)

## 
#  Default values for variables in config.R

library(duckdb)
library(DBI)
library(ifnBase)
library(workspace)

# Name of the file to load containing platform definition (surveys, table mapping, ...)
PLATFORM_FILENAME = "default_platform"
TRANSLATION_FILES = share.data.path( c("i18n/common.en.json", "i18n/intake.en.json", "i18n/weekly.en.json"))


#' Load configuration files and setup ifnBase package
load_config = function() {

  config.path = file.path(project.root, "config")

  if(!file.exists(config.path)) {
     stop(paste0("Config directory is not found ",sQuote(config.path),". Are you runnning script in root of the directory as working directory"))
  }
  
  config_file = file.path(config.path, "config.R")
  
  if(!file.exists(config_file)) {
    stop(paste0("file config.R found in config/ directory (", sQuote(config.path),"), did you configure the project"))
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
  
  out.path = get0("OUTPUT_PATH", ifnotfound = "output")
  
  if(!endsWith(out.path, suffix = "/")) {
    out.path = paste0(out.path, "/")
  }
  
  options(workspace.outpath=out.path)
  share.option(platform=PLATFORM_FILENAME, country=EUROSTAT_COUNTRY)
  
  invisible()
}

load_translation = function(files) {
  for(file in files) {
    r = jsonlite::read_json(file)
    if(!is.list(r)) {
      rlang::abort(paste("Error reading translation file", sQuote(file), "must only contain an object"))
    }
    n = which(names(r) == "#") # Remove comment
    if(length(n)) {
      r = r[-n]
    }
    i18n_set(!!!r)
  }
  # Ensure
  i18n_set("#"="")
}

load_config()
ifnBase::load_platform()
load_translation(TRANSLATION_FILES)