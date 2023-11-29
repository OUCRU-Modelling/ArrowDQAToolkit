#' Utility function - Custom summary function for arrow object  
#'
#' @param data - arrow data table to analyze, can be passed via pipe
#' @param var - variables to generate summary
#' @param ... 
#'
#' @return
#' @import arrow tidyverse rlang
#' @export
#'
#' @examples
arrow_summary <- function(data, var, ...){
  if(!(class(var) == "character")){
    stop("Given variable must be a character")
  }
  
  # NOTE: 
  # - somehow tidyeval {{}} cannot work with arrow's group_by
  # - work around to work with return value by arrow implementation of group_by 
  
  query <- str_interp(
    "data %>%  summarize(
    min_value = min(${var}, na.rm=TRUE),
    first_quantile = quantile(${var}, probs = (0.25), na.rm=TRUE),
    mean_value = mean(${var}, na.rm=TRUE),
    median_value = median(${var}, na.rm=TRUE),
    third_quantile = quantile(${var}, probs = (0.75), na.rm=TRUE),
    max_value = max(${var}, na.rm=TRUE),
    sd_value = sd(${var}, na.rm=TRUE)
    )"
  )
  
  eval(parse_expr(query))
  
}