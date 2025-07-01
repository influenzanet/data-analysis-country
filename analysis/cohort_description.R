##
# Describe the cohort participants profile for a season
##

workspace::launch() # Load the common library and find the root path
share.lib('describe') # Load describe script in lib/ (share.lib knows the path)

# To change season number do not modify this line, run this script in another script using source()
# And defining the season you want.
season = get0("season", ifnotfound = calc_season(Sys.Date()))

init_path(file.path('cohort_description', season))

gg_labs = function(...) {
  labs(..., 
    subtitle=paste(i18n("season"), season),
    caption=paste0(i18n("copyright_graph"),", ", Sys.time())
  )
}

condition.columns = survey_labels('intake', 'condition')
hear.columns = survey_labels('intake', 'hear.about')
allergy.columns = survey_labels('intake', 'allergy')
pets.columns = survey_labels('intake', 'pets')
education.columns = survey_labels("intake","education")
diet.columns = survey_labels("intake", "diet")

intake.columns = '*'

intake = survey_load_results("intake", '*', season = season)

# Load weekly with only timestamp to build the participants db
weekly = survey_load_results("weekly", 'timestamp', season=season)
weekly = keep_last_survey(weekly)

intake = keep_last_survey(intake)

intake = complete_intake(weekly, intake, intake.columns = "*")

# Only keep intake with at least a weekly (minimal "active" participant)
intake = intake[intake$person_id %in% weekly$person_id, ]

intake = recode_intake(intake)

# Collect results to save them
results = DataCollector$new()

d = freq_var(intake, gender, na.rm=TRUE) 
results$collect("gender", d)

plot_freq(d) + gg_labs(title=i18n("gender_graph"))
ggsave(my_path("gender.pdf"), width = 8, height=6)

# Age categories, by 10. 200 over maximum expected and will be replaced by max observed.
age.categories = c(seq.int(0, 80, by=10), 200)

intake$age.cat = cut_age(intake$age, age.categories)

d = freq_var(intake, age.cat)
results$collect("age.cat", d)

plot_freq(d) + gg_labs(title=i18n("age_group_graph"))
ggsave(my_path("age_group.pdf"), width = 8, height=6)

# Main activity & Occupation
d = freq_var(intake, main.activity)
results$collect("main_activity", d)
plot_freq(d) + 
  gg_labs(title=i18n("graph_main_activity")) +
  theme(axis.text.x = element_text(angle=75, vjust = 0.5)) 

if(hasName(intake, "occupation")) {
  d = freq_var(intake, occupation)
  results$collect("occupation", d)
  plot_freq(d) + gg_labs(title=i18n("graph_pregnant"))
}

## Pregnancy

if(hasName(intake, "pregnant")) {
 d = freq_var(intake, pregnant)
 plot_freq(d) + gg_labs(title=i18n("graph_pregnant"))
}

## Edudation
d = freq_bool(intake, education.columns)
if(nrow(d) > 0) {
  plot_freq(d) + gg_labs(title=i18n("graph_education"))
}

## Diet

d = freq_bool(intake, diet.columns)
if(nrow(d) > 0) {
  plot_freq(d) + gg_labs(title=i18n("graph_education"))
}


## Condition

d = freq_bool(intake, condition.columns)
results$collect("condition", d)

plot_freq(d) + 
  theme(axis.text.x = element_text(angle=75, vjust = 0.5)) +
  gg_labs(title=i18n("graph_condition"))
ggsave(my_path("condition_all.pdf"), width = 8, height=6)

plot_freq(d %>% filter(var !="condition.none"), percent = TRUE) + 
  theme(axis.text.x = element_text(angle=75, vjust = 0.5)) +
  gg_labs(title=i18n("graph_condition"))
ggsave(my_path("condition_but_none.pdf"), width = 8, height=6)

## Distribution by age & gender and Age pyramid

pop = load_population_age("country", ifnBase::max_year_available(season), age.categories)
pop = tidyr::pivot_longer(pop %>% select(age.cat, male, female), c('male','female'), names_to = "gender", values_to = "count")
pop$pop = "pop"

intake.age = intake %>%
  group_by( age.cat, gender) %>%
  count(name="count") %>%
  mutate(pop="cohort")

ages = bind_rows(intake.age, pop)

ages = ages %>% 
  filter(gender %in% c('male','female')) %>%
  group_by(pop) %>% 
  mutate(prop=count / sum(count))

# Expression to select female rows
q_female = quo(gender == "female")

plot_age_pyramid(ages, female=q_female, scales=list(labels=c('pop'=i18n("population.title"), "cohort"=i18n("cohort.title")))) + 
    gg_labs(
      title=i18n("graph_age_pyramid"),
      x=i18n("age_group"),
      y=i18n("age_gender_proportion")
    )

ggsave(my_path("age_pyramid.pdf"), width = 8, height=6)

d = tidyr::pivot_wider(ages %>% select(age.cat, gender, count, pop), id_cols = c('age.cat', 'gender'), names_from = 'pop', values_from = "count")
results$collect("age_gender", d)

results$save(my_path("datasets.rds"), meta=list(country=share.option('country'), season=season))
