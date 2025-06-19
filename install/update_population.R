source("lib/common.R")
source("lib/population.R")

pop = load_eurostat_population(NULL, level=0, min.year = 2010)

dir.create("data/pop")

pop.age = pop$pop.age

if(!hasName(pop.age, "year.ref")) {
  pop.age$year.ref = pop.age$year
}

by(pop.age, pop.age$country, function(p) {
  country = p$country[1]
  p = p %>% select(all, male, female, year.ref, age.min, age.max, year)
  fn = paste0(country, "_pop_age5_country.csv")
  write.csv2(p, file.path("data/pop", fn), row.names = FALSE)
})

#pop.nuts1 = load_eurostat_population(NULL, level=1, min.year = 2010)
