#' Prepare item level metadata
#' 
#' Read item level metadata 
#'
#' @param path - path to the metadata folder
#'
#' @return a data.table for item level metadata
#' @import readxl data.table arrow tidyverse
#' @export
#'
#' @examples
prep_item_metadata <- function(path=NULL){
  # Read and process item level metadata
  # Metadata type to support: excel mostly following dataquieR convention
  # Return data table object 
  
  if(is.null(path)){
    # default to current working directory if path is note provided
    path = file.path(getwd(), "metadata", "item_level.xlsx")
  }else{
    # default to current working directory if path is note provided
    path = file.path(path, "metadata", "item_level.xlsx")
  }
  item_metadata <- as.data.table(read_excel(path=path, sheet=1))
  
  # --- Making sure all required columns is there
  required_columns = c("variable", "datatype", "limit","labels", "missing_labels")
  metadata_columns = colnames(item_metadata)
  
  if(!all(required_columns %in% metadata_columns)){
    stop(str_interp("Metadata must contains all required columns \n
         Expected ${required_columns}\n
         Found ${metadata_columns}"))
  }
  
  # --- Making sure datatype of all variables is specified
  # get number of na in datatype
  na_count <- colSums(is.na(item_metadata[, "datatype"]))
  if(!(na_count["datatype"] == 0)){
    stop("Datatypes for all variables must be specified")
  }
  
  # --- Making sure that datatype mentioned in excel matches expected types
  expected_types = c("string", "integer", "float", "datetime", "logical")
  metadata_types = unique(item_metadata$datatype)
  
  if(!all(metadata_types %in% expected_types)){
    stop(str_interp("Receive unexpected datatypes in metadata \n
         Expected ${expected_types}\n
         Found ${metadata_types}"))
  }
  
  # --- Return metadata as data table
  return(item_metadata)
}

#' Prepare cross-item level metadata
#' 
#' Read cross-item level metadata 
#'
#' @param path - path to the metadata folder
#'
#' @return a list of 2 data.table:
#' - multivariates - define multivariate variables
#' - contradiction - contradiction rules
#' @import readxl data.table arrow tidyverse
#' @export
#'
#' @examples
prep_crossitem_metadata <- function(path=NULL){
  # Read and process item level metadata
  # Metadata type to support: excel mostly following dataquieR convention
  # return JSON like object (?) 
  
  if(is.null(path)){
    # default to current working directory if path is note provided
    path = file.path(getwd(), "metadata", "cross_item_level.xlsx")
  }else{
    # default to current working directory if path is note provided
    path = file.path(path, "metadata", "cross_item_level.xlsx")
  }
  
  multivariate_vars <- as.data.table(read_excel(path=path, sheet=1))
  constraints <- as.data.table(read_excel(path=path, sheet=2))
  
  # --- Making sure all required columns are there
  required_columns = c("variables", "label", "check_unique", "check_missing")
  required_constraint_colums = c("label", "contradiction", "rule")
  metadata_columns_1 = colnames(multivariate_vars)
  metadata_columns_2 = colnames(constraints)
  
  if(!all(required_columns %in% metadata_columns_1)){
    stop(str_interp("Sheet 1 of metadata must contains all required columns \n
         Expected ${required_columns}\n
         Found ${metadata_columns_1}"))
  }else if (!all(required_constraint_colums %in% metadata_columns_2)){
    stop(str_interp("Sheet 2 of metadata must contains all required columns \n
         Expected ${required_constraint_colums}\n
         Found ${metadata_columns_2}"))
  }
  
  # --- Making sure all non-nullable columns contains value
  # get number of na in datatype
  na_count <- colSums(is.na(multivariate_vars[, c("variables", "label", "check_outlier", "check_unique", "check_missing")]))
  for (col in colnames(na_count)){
    if(!(na_count[col] == 0)){
      stop(str_interp("${col} for all variables in sheet 1 must be specified"))
    }
  }
  na_count <- colSums(is.na(constraints[, c("label", "contradiction")]))
  for (col in colnames(na_count)){
    # get number of na in datatype
    if(!(na_count[col] == 0)){
      stop(str_interp("${col} for all variables in sheet 2 must be specified"))
    }
  }
  
  # --- Convert columns with logical values to correct typing
  bool_columns <- c("check_outlier", "check_unique", "check_missing")
  for (col in bool_columns){
    multivariate_vars[[col]] <- as.logical(multivariate_vars[[col]])
  }
  
  
  # --- Return cross_item_metadata
  cross_item_metadata <- list("multivariate_vars"=multivariate_vars,
                              "contradictions"=constraints)
  
  return(cross_item_metadata)
}


