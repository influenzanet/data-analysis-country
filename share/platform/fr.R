
colors = c('primary'="#7AB800","secondary"="#007AB8")

language = 'fr'

# Survey using the european template
platform_define_survey(
  "intake",
  survey_id=8,
  single.table=F,
  table = "pollster_results_intake",
  template="eu:intake",
  geo.column="Q3",
  mapping = list(
    "hear.internet"=variable_available("Q17_2", rlang::quo(season < 2017))
  )
)


platform_define_survey(
  "weekly",
  single.table=F,
  survey_id=9,
  table = "pollster_results_weekly",
  template = "eu:weekly"
)

seasons = list(
  list(2011, pop=2012),
  list(2012, pop=2012),
  list(2013, pop=2013),
  list(2014, pop=2014),
  list(2015, pop=2015),
  list(2016, pop=2016),
  list(2017, pop=2017),
  list(2018, pop=2018),
  list(2019, pop=2018)
)

for(season in seasons) {
  y = season[[1]]
  platform_season_history(y,
      weekly=paste0('pollster_results_weekly_',y),
      intake=paste0('pollster_results_intake_',y),
      health=paste0('pollster_health_status_',y),
      dates=list('start'=paste0(y, '-11-20'), 'end'=paste0(y + 1, '-04-20')),
      year.pop=season$pop
  )
}

platform_options(
  first.season.censored=FALSE,
  complete.intake=list(
    max.year=2
  ),
  default_language = 'en',
  use.country = FALSE,
  population.loader = "age",
  country = "FR",
  population.age.loader = 'country_file'
)

platform_geographic_levels(
  c('zip', 'nuts3', 'nuts2', 'nuts1', 'country'),
  # level code of the information in the survey
  level.base = 'zip',
  table = 'geo_levels',
  columns = c('zip'='code_com', 'nuts3'='code_dep','nuts2'='code_reg', 'nuts1'='code_irg', 'country'='country'),
  hierarchies=list(
    'admin'=c('zip','nuts3','nuts2','nuts1','country')
  ),
  default.hierarchy="admin"
)

# List of geographic tables describing areas of each level
# name=level code
platform_geographic_tables(list(
  'zip'=list(table='pollster_zip_codes', title=NULL, column='zip_code_key'),
  'nuts3'=list(table='gis_departement',title='nom_dept', column='code_dept', zones=list('nuts2'='code_reg'), population_table="pop_dep"),
  'nuts2'=list(table='gis_region', title='nom_region', column='code_reg', zones=list('nuts1'='code_irg'), population_table="pop_reg"),
  #'rdd'=list(table='gis_region2016', title='title', column='code_rdd', zones=list('irg'='code_irg')),
  'nuts1'=list(table="gis_interregion", title="title", column="code_irg", population_table="pop_irg"),
  'country'=list()
))

