
colors.web = list('green'="#7AB800","blue"="#007AB8")

language = 'fr'

# Survey using the european template
platform_define_survey(
  "intake",
  survey_id=8,
  single.table=F,
  table = "pollster_results_intake",
  template="eu:intake",
  geo.column="Q3"
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
  use.country = FALSE
)
