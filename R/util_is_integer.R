# util to check integer from dataquier
#' Utility to check whether a vector only contains integer
#'
#' @param x - object to †est 
#' @param tol - precision of the detection. Values deviating more than `tol` from
#'            their closest integer value will not be deemed integer.
#'
#' @return boolean value of whether vector only contains integer
#' @import arrow tidyverse
#' @export
#'
#' @examples
util_is_integer <- function(x, tol = .Machine$double.eps^0.5) {
  if (is.numeric(x)) {
    r <- abs(x - round(x)) < tol & !is.nan(x)
    # & x <= .Machine$integer.max & this would return, whether x can be stored as an integer.
    #   x >= - .Machine$integer.max
  } else {
    r <- rep(FALSE, length(x))
  }
  r[is.na(r)] <- TRUE # NA is not not an integer
  
  return(length(r[r==FALSE]) == 0)
}




