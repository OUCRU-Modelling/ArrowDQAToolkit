#' Compute outliers
#'
#' @param data 
#' @param var - variable to calculate outlier, expected to be a numeric variable
#'
#' @import rlang arrow tidyverse
#' @return
#' @export
#'
#' @examples
util_compute_outliers <- function(data, var){
  filter_expression <- str_interp(
    "data %>%
      summarize(
        first_q = quantile(${var}, probs = (0.25), na.rm=TRUE),
        third_q = quantile(${var}, probs = (0.75), na.rm=TRUE)
      ) %>%
      mutate(
        lower_bound = first_q - 1.5*(third_q - first_q),
        higher_bound = third_q + 1.5*(third_q - first_q),
        .keep = \"unused\"
      ) %>%
      collect()"
  )
  
  bounds <- eval(parse_expr(filter_expression))
  
  query_upper_outliers <- str_interp(
    "
      data %>% 
        dplyr::filter( ${var} > bounds[[1, \"higher_bound\"]]) %>% 
        compute()
      "
  )
  query_lower_outliers <- str_interp(
    "
      data %>% 
        dplyr::filter( ${var} < bounds[[1, \"lower_bound\"]]) %>% 
        compute()
      "
  )
  
  upper_outliers <- eval(parse_expr(query_upper_outliers))
  lower_outliers <- eval(parse_expr(query_lower_outliers))
  
  outliers <- concat_tables(upper_outliers, lower_outliers)
  
  # free used memory
  rm(upper_outliers)
  rm(lower_outliers)
  gc()
  
  return(outliers)
}