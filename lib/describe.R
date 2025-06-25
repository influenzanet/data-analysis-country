## 
# Helpers for descriptive analysis
##

library(dplyr)
library(ggplot2)

#' Simple Frequency table
freq_var = function(data, variable, na.rm=FALSE) {
  variable = ensym(variable)
  d = data %>% 
        group_by(level={{ variable }}) %>% 
        count() %>% 
        ungroup()
  if(na.rm) {
    d = filter(d, !is.na(level))
  }
  class(d) <- c("freq_var", class(d))
  d
}

select_columns = function(data, columns) {
  nn = names(data)
  missing = columns[!columns %in% nn]
  columns = columns[ columns %in% nn]
  if(length(missing) > 0) {
    rlang::warn(paste("Missing columns", paste(sQuote(missing), collapse = ", ")), class="missing_columns")
  }
  columns                   
}

#' Frequency of a list of boolean variable
freq_bool = function(data, columns) {
  columns = select_columns(data, columns)
  dd = bind_rows(lapply(columns, function(column) {
    name = sym(column)
    data %>% 
      summarise(
        total=n(), 
        missing=sum(is.na(!!name)),
        count=sum(!!name, na.rm=TRUE)
      ) %>% 
      mutate(total_value=total-missing, var=!!column) %>% 
      ungroup()    
  }))
  class(dd) <- c("freq_bool", class(dd))
  dd
}

DataCollector = R6::R6Class("DataCollector", public=list(
  datasets=list(),
  collect=function(name, data) {
     self$datasets[[name]] = data
  }
))

plot_freq = function(x, ...) {
  UseMethod("plot_freq", x)
}

plot_freq.freq_var = function(x, trans=TRUE, fill.color="steelblue", ...) {
  x = data.frame(x)
  na.row = x %>% filter(is.na(level))
  
  if(trans) {
    l = i18n
  } else {
    l = identity
  }
  
  d = x %>% filter(!is.na(level))
  
  g = ggplot(d, aes(x=l(level), y=n)) + 
        geom_bar(stat="identity", fill=fill.color) +
      labs(x="", y=l("axis.count.participants"))
  
  
  g
}

plot_freq.freq_bool = function(x, trans=TRUE, fill.color="steelblue", percent=FALSE, order.freq=TRUE, ...) {
  x = data.frame(x)
  if(trans) {
    l = i18n
  } else {
    l = identity
  }
  
  if(percent) {
    y = quo(100*count/total_value)
    ylab = "axis.percent"
  } else {
    y = quo(count)
    ylab = "axis.count.participants"
  }
  
  if(order.freq) {
    d = x %>% arrange(desc(count))
  } else {
    d = x
  }
  
  g = ggplot(d, aes(x=l(var), y=!!y)) + 
    geom_bar(stat="identity", fill=fill.color) +
    labs(x="", y=l(ylab))
  g
}


