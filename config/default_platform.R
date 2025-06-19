###
# Default Platform file 
# Define available surveys and their mapping
# It's advised to not edit this file by hand, but define new file and define `PLATFORM_FILE` to it's name
## 

# Common table names for all seasons in the duckdb database
tables=list(
  intake="pollster_results_intake",
  weekly="pollster_results_vaccination",
  vaccination="pollster_results_vaccination"
)

# platform_define_survey() registers survey and their structure (using template)
# It's possible to add extra columns & define mapping, recoding 
# Templates are defined in ifnBase, can be viewed with survey_template('eu:intake') or in the package source
platform_define_survey("intake", single.table=T, table = tables$intake, template="eu:intake", geo.column="Q3")
platform_define_survey("weekly", single.table=T, table = tables$weekly, template="eu:weekly")
platform_define_survey("vaccination", single.table=T, table = tables$vaccination,template="eu:vaccination")

# Define available seasons, each season has to be described (season is identified by the starting year number) 
# Use generator function `platform_generate_seasons` to define the same for all seasons
# Seasons dates are starting each year  1st september by default.
# It's possible to specify season by season using `platform_season_history`() or to update entries the returned list before call of `platform_set_seasons`
seasons = platform_generate_seasons(from=2020, tables=tables)
platform_set_seasons(seasons)
