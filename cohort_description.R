source("lib/common.R")
source("lib/describe.R")

init.path('cohort_description')

season = calc_season(Sys.Date())

condition.columns = survey_labels('intake', 'condition')
hear.columns = survey_labels('intake', 'hear.about')
allergy.columns = survey_labels('intake', 'allergy')

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

plot_freq(d) + labs(title=i18n("gender_graph"))
ggsave(my.path("gender.pdf"), width = 8, height=6)

# Age categories, by 10. 200 over maximum expected and will be replaced by max observed.
age.categories = c(seq.int(0, 80, by=10), 200)

intake$age.cat = cut_age(intake$age, age.categories)

d = freq_var(intake, age.cat)
results$collect("age.cat", d)

plot_freq(d) + labs(title=i18n("age_group_graph"))
ggsave(my.path("age_group.pdf"), width = 8, height=6)

d = freq_var(intake, main.activity)
results$collect("main_activity", d)

d = freq_var(intake, main.activity)
results$collect("main_activity", d)

d = freq_bool(intake, condition.columns)
results$collect("condition", d)

plot_freq(d) + 
  theme(axis.text.x = element_text(angle=75, vjust = 0.5)) +
  labs(title=i18n("condition_graph"))
ggsave(my.path("condition_all.pdf"), width = 8, height=6)

plot_freq(d %>% filter(var !="condition.none"), percent = TRUE) + 
  theme(axis.text.x = element_text(angle=75, vjust = 0.5)) +
  labs(title=i18n("condition_graph"))
ggsave(my.path("condition_but_none.pdf"), width = 8, height=6)


