#' Utility function - Mapping value range operator to the built in function
#'
#' @param data - arrow data table
#' @param var - variable for fitlering
#' @param datatype - datatype of variable
#' @param lower_bound - lowerbound value
#' @param higher_bound - higherbound value
#' @param greater - "(" or "["
#' @param less - ")" or "]"
#'
#' @return
#' @import tidyverse arrow 
#' @importFrom stats setNames
#' @export
#'
#' @examples

mapping_filter_condition <- function(data, var, datatype, lower_bound, higher_bound, greater, less){
  supported_type = c("integer", "float", "datetime")
  
  if(!(datatype %in% supported_type)){
    stop(str_interp("${datatype} is not suppported for filtering function"))
  }
  
  # mapping data type to correct type casting function
  type_casting <- setNames(
    list(as.integer, as.double, dmy),
    nm = c("integer","float","datetime")
  ) 
  
  # mapping signs to the correct filtering condition
  lower_mapping <- function(data,var,  sign, val){
    if(sign == "]"){
      data <- data %>% 
        dplyr::filter(
          arrow_less_equal({{var}}, val)
        )
    }else if(sign == ")"){
      data <- data %>% 
        dplyr::filter(
          arrow_less({{var}}, val)
        )
    }
    return(data)
  }
  greater_mapping <- function(data, var, sign, val){
    if(sign == "["){
      data <- data %>% 
        dplyr::filter(
          arrow_greater_equal({{var}}, val)
        )
    }else if(sign == "("){
      data <- data %>% 
        dplyr::filter(
          arrow_greater({{var}}, val)
        )
    }
    return(data)
  }
  
  # --- Cast the bounds to the correct typing
  lower_bound <-  type_casting[[datatype]](lower_bound)
  higher_bound <-  type_casting[[datatype]](higher_bound)
  
  # --- Check whether lower bound and higher bound was defined
  if (!is.na(lower_bound) && !is.na(higher_bound)){
    return(
      data %>%
        lower_mapping({{var}}, less, higher_bound) %>% 
        greater_mapping({{var}}, greater, lower_bound) 
    )
  }else if (is.na(lower_bound)){
    return(
      data %>%
        lower_mapping({{var}}, less, higher_bound) 
    )
  }else if (is.na(higher_bound)){
    return(
      data %>%
        greater_mapping({{var}}, greater, lower_bound)
    )
  }else{
    stop("Neither lower bound or higher bound was given ")
  }
  
}