#' Perform all Intrinsic quality assessment
#'
#' @param metadata_path - path to the data folder
#' @param data - arrow data table
#'
#' @return
#' @import data.table
#' @export
#'
#' @examples

intrinsic_eval <- function(metadata_path, data){
  item_metadata <- prep_item_metadata(path=metadata_path)
  cross_item_metadata <- prep_crossitem_metadata(path=metadata_path)
  
  # --- Test code for checking integrity
  print("--- Integrity - datatype")
  # coerce to specified datatypes before computing next steps
  data <- int_datatype(data, item_metadata)
  
  gc()
  print("--- Integrity - duplicates")
  duplicate_result <- int_duplicates(data, cross_item_metadata=cross_item_metadata)
  print(duplicate_result$result)
  
  gc()
  # --- Test code for consistency
  print("--- Consistency - values within specified range")
  print(con_range(data, item_metadata))
  print("--- Consistency - label variables")
  print(con_label(data, item_metadata, path=metadata_path))
  print("--- Consistency - value contradiction")
  contradiction_result <- con_contradiction(data, cross_item_metadata)
  print(contradiction_result$result)
  gc()
  
  # --- Test code for completeness
  print("--- Completeness - crude missingness")
  crude_missing <- com_crude_missing(data, item_metadata, cross_item_metadata)
  print(crude_missing$univariate_result)
  print(crude_missing$multivariate_result)
  print("--- Completeness - qualified missingness")
  print(com_qualified_missing(data, item_metadata))
  gc()
  
  # --- Test code for accuracy
  print("--- Accuracy - Univariate outliers")
  uni_outlier <- acc_uni_outliers(data, item_metadata)
  print(uni_outlier$result)
}