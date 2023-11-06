
#' Assess Accuracy - Univaritate Outliers
#' 
#' check for univariate outliers
#' definition of outliers: based on method introduced by Tukey in 1977
#' - less than 1.5*IQR away from 1st quantile
#' - greater than 1.5*IQR away from the 3rd quantile
#' @param data - arrow data table
#' @param metadata - item level metadata, expected data table object generated by prep_metadata function
#'
#' @return a result data.frame 
#' @import rlang data.table tidyverse arrow
#' @export
#'
#' @examples
acc_uni_outliers <- function(data, metadata){
  supported_type = c("integer", "float", "datetime")
  
  var_type <- as.data.frame(metadata[,c("variable", "datatype")])
  n_data <- data$num_rows
  
  varnames <- character(0)
  no_outliers <- character(0)
  percentage <- double()
  var_outliers <- list()

  for(row in 1:nrow(var_type)){
    var <- var_type[row, "variable"]
    type <- var_type[row, "datatype"]
    
    if (!(type %in% supported_type)){
      next 
    }
    
    if (type == "datetime"){
      # if datatype is datetime, cast to integer before checking outlier
      cast_exp <- str_interp("data$${var} <- data$${var}$cast(arrow::int32())")
      eval(parse_expr(cast_exp))
    }
    
    outliers <- util_compute_outliers(data, var)
    
    # cast back to date datatype when done processing
    if (type == "datetime"){
      # if datatype is datetime, cast to integer before checking outlier
      cast_exp <- str_interp("outliers$${var} <- outliers$${var}$cast(arrow::date32())")
      eval(parse_expr(cast_exp))
    }
    
    
    varnames <- append(varnames, var)
    no_outliers <- append(no_outliers, str_interp("${nrow(outliers)}/${n_data}"))
    percentage <- append(percentage, (nrow(outliers)/(n_data)))
    var_outliers[[var]] <- outliers
    
    gc()
  }
  
  return(list(
    "result" = data.frame(varnames, no_outliers, percentage), 
    "outliers" = var_outliers
  ))
}

