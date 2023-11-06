#' Utility to check each row whether they are duplicate or not
#'
#' @param data - arrow data table 
#' @param vars - variables to check for duplicates
#'
#' @return
#' @import rlang arrow tidyverse 
#' @export
#'
#' @examples

util_compute_duplicates <- function(data, vars){
  
  no_rows <- data$num_rows 
  
  # --- Generate expression for type casting 
  # casting_exp <- character(length(vars))
  # for (row in 1:length(vars)){
  #   casting_exp[row] <- str_replace(vars[row], vars[row], str_interp("${vars[row]}=arrow::cast(${vars[row]}, arrow::string())"))
  # }
  # casting_exps <- str_c(casting_exp, sep=",", collapse = ",")
  # # print(casting_exps)
  # casting_exps <- str_interp("data %>% dplyr::mutate(${casting_exps}, .keep=\"none\")")
  # # create data parsed to string for concatenation
  # parsed_data <- eval(parse_expr(casting_exps))
  # 
  # # deallocate memory used for data and use parsed data instead
  # rm(data)
  # gc()
  
  # --- Generate expression for concatenating
  concat_vars <- str_c(vars, sep=",", collapse = ",")
  concat_exp <- str_interp("data %>% 
                           mutate(combined = paste(${concat_vars}, sep=\"\")) %>% 
                           select(combined) %>% 
                           compute()")
  combinations <- eval(parse_expr(concat_exp))
  
  # load concatenated combinations in memory
  # concat <- combinations %>% select(combined) %>% collect()
  
  # get data after filtering duplicates  
  is_duplicates <- duplicated(combinations$combined$as_vector())

  gc()
  return(is_duplicates)
}