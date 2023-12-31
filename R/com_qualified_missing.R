#' Assess Completeness - Qualified missing
#'
#' @param data - arrow data table
#' @param metadata - item level metadata, expected data table object generated by prep_metadata function
#'
#' @return result summary data.frame
#' 
#' @import data.table arrow tidyverse rlang
#' @export
#'
#' @examples
com_qualified_missing <- function(data, metadata, plot_result = FALSE){
  # get variables with missing labels
  var_label <- as.data.frame(metadata[!is.na(missing_labels), c("variable","datatype", "missing_labels")])
  
  # get total number of data
  no_data <- data$num_rows
  
  # --- Check qualified missingness for each variable
  varname <- character(0)
  missing_label <- character(0)
  no_missing <- character(0)
  percentage <- double()
  
  if(nrow(var_label) > 0){
    for (row in 1:nrow(var_label)){
      curr_varname <- var_label[row, "variable"]
      labels <- var_label[row, "missing_labels"]
      
      # get missing labels
      labels <- str_split(labels, " \\| ")[[1]]
      
      for (label in labels){
        
        # get number of rows having label value
        no_missing_query <- str_interp(
          "data %>% dplyr::filter(${curr_varname} == ${label}) %>% compute() %>% nrow()"
        )
        if (var_label[row, "datatype"] == "string"){
          no_missing_query <- str_interp(
            # special handling for string datatype
            "data %>% dplyr::filter(${curr_varname} == \"${label}\") %>% compute() %>% nrow()"
          )
        }
        
        curr_no_missing <- eval(parse_expr(no_missing_query))
        
        varname <- append(varname, curr_varname)
        missing_label <- append(missing_label, label)
        no_missing <- append(no_missing, str_interp("${curr_no_missing}/${no_data}"))
        percentage <- append(percentage, curr_no_missing*100/no_data)
      }
    }
  }
    
  result <- data.frame(varname, missing_label, no_missing, percentage)
  
  if(plot_result){
    print(util_graphing_percentage(result, varname, title = "Percentage of qualified missing"))
  }
  return(result)
}
