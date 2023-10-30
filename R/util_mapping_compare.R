#' Utility to map operator to comparison function
#'
#' @param data 
#' @param var1 
#' @param var2 
#' @param operator 
#'
#' @return
#' @import arrow reticulate
#' @export
#'
#' @examples
util_mapping_compare <- function(data, var1, var2, operator){
  # expose pyarrow compute functions to arrow 
  pa <- import("pyarrow.compute")
  
  operator_mapping <- setNames(
    list(pa$less_equal, pa$less, pa$greater, pa$greater_equal),
    nm = c("<=", "<", ">", ">=")
  ) 
  
  return(
    operator_mapping[[operator]](data[[var1]], data[[var2]])
  )
}