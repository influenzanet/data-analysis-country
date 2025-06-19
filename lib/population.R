library(dplyr)
library(stringr)
library(forcats)

if(!library(eurostat, logical.return = TRUE)) {
  install.packages("eurostat")
  library(eurostat)
}

load_eurostat_population = function(country, level, min.year,  exclude.levels=NULL) {
  
  pop_eu = get_eurostat("demo_r_pjangroup", type="code")
  
  pop_eu$year = as.integer(format(pop_eu$TIME_PERIOD, "%Y"))
  
  pop_eu$country = substr(pop_eu$geo, 1, 2)
  
  pop_eu$level = nchar(as.character(pop_eu$geo)) - 2
  
  if(!is.null(country)) {
    d = pop_eu %>% filter(country==!!country)
  } else {
    d = pop_eu
  }
  
  d = d %>% filter(level==!!level, year >= min.year)
  
  d$sex = factor(d$sex)
  d$sex = forcats::fct_recode(d$sex, "female"="F", "male"="M", "all"="T")  

  pop.allages = d %>% filter(age == "TOTAL")
  
  pop.allages = tidyr::pivot_wider(pop.allages %>% select(sex, geo, year, values), names_from = "sex", values_from = "values", id_cols = c('geo', 'year'))
  
  pop.allages = pop.allages %>% arrange(year, geo)

  pop.age = d %>% filter(age != "TOTAL")
  
  ages = extract_age_groups(pop.age)
  
  check_age_groups(ages)
  
  pop.age = tidyr::pivot_wider(pop.age %>% select(sex, age, geo, values, year), names_from = "sex", values_from = "values", id_cols = c('age','geo','year'))
  
  unk = pop.age %>% filter(age=="UNK") %>% summarize(across(c(female, male, all), sum))
  
  if(all(as.vector(unk) == 0)) {
    message("No data for unknown age group, can safely remove it")
    pop.age = pop.age %>% filter(age != "UNK")
  }
  
  check_dims = function(year, dim, name) {
    tt = table(year, dim)
    m = max(tt)
    if(!all(tt == m)) {
      print(paste("Dimension ", name, "vary across years"))
    }
  }
  
  message("Checking pop.age dimensions")
  check_dims(pop.age$year, pop.age$age, "age")
  check_dims(pop.age$year, pop.age$geo, "geo")
  
  pop.age = left_join(pop.age, ages[, c('age','age.min', 'age.max')])
  
  if(is.null(country)) {
    pop.age$country = substr(pop.age$geo, 1, 2)
    pop.allages$country = substr(pop.allages$geo, 1, 2)
  }
  
  # Remove classes not mapped to age value
  pop.age = pop.age[ !is.na(pop.age$age.min) & !pop.age$age == "UNK", ]
  
  pop.age = pop.age %>% arrange(year, geo, age.min)

  list(pop.allages=pop.allages, pop.age=pop.age, age.groups=ages)
}


extract_age_groups= function(pop.age) {
  
  ages = pop.age %>% group_by(age) %>% summarize(n_year=n_distinct(year))
  
  groups = stringr::str_match(ages$age, "^Y([0-9]+)\\-([0-9]+)")
  groups = groups[, -1]
  colnames(groups) <- c('age.min','age.max')
  groups = data.frame(groups)
  
  ages = cbind(ages, groups)
  
  
  i = ages$age == "Y_LT5"
  ages$age.min[i] = 0
  ages$age.max[i] = 4
  
  i = grepl("^Y_GE([0-9]+)", ages$age)
  group = as.numeric(gsub("^Y_GE([0-9]+)","\\1", ages$age[i]))
  ages$age.min[i] = group
  ages$age.max[i] = NA
  
  ages$age.min = as.integer(ages$age.min)
  ages$age.max = as.integer(ages$age.max)
  
  # Select optimal bound (greatest age with all countries)
  ages$bound = is.na(ages$age.max) & !is.na(ages$age.min)
  
  max.year = max(ages$n_year)
  
  # Find bound with max years (cover all years)
  max.bound = max(if_else(ages$bound & ages$n_year == max.year, ages$age.min, 0))
  
  ages$max.bound = ages$age.min == max.bound
  
  ages = ages %>% filter(!bound | max.bound)
  ages = ages %>% arrange(age.min)
  ages = ages %>% mutate(age.unknown = is.na(age.min) & is.na(age.max))
  
  ages
}

# Check age groups are exclusives
check_age_groups = function(groups) {
  
  groups = groups %>% filter(!age.unknown)
  
  ages = 1:120
  
  groups$age.max[is.na(groups$age.max)] = max(ages)
  
  errors = NULL
    
  for(age in ages) {
    g = age >= groups$age.min & age <= groups$age.max
    if(sum(g) > 1) {
       d = data.frame(age=age, group=groups$age[g])
       errors = bind_rows(errors, d)
    }
  }
  
  if(!is.null(errors) && nrow(errors) > 0) {
    print("Errors checking age groups, age limit doesnt seem exclusive")
    print(errors)    
    rlang::abort("Non exclusive age groups")
  }
}

