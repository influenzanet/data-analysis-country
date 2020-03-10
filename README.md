# data-analysis-country
Country specific data analysis for Influenzanet platform

# Files organization

This repository follows the workspace organization described in ifnBase package [vignette workspace](https://github.com/cturbelin/ifnBase/blob/master/vignettes/workspace.Rmd)

- share: contains scripts & data shared across projects & platform definition files 
- overview: project, global analysis of a platform data

R scripts must run in a project directory (i.e: with their project directory as R working directories), all path must be relatives to this directory.


# Requirements

- R >= 3.4
- [ifnBase package](https://github.com/cturbelin/ifnBase)
- packages : dplyr (>=0.7.5), rlang, ggplot2 (>=3.2)

# Installation

In the root of this repository run share/install.R

```R
source('share/install.R')
```

