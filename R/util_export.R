#' Utility function - Export data
#'
#' Save data that failed the checks as an excel file
#' @param data - data returned by evaluation functionss
#' @param outfile_name - name of the output file
#'
#' @return
#' @export
#' @importFrom writexl write_xlsx
#'
#' @examples
util_export <- function(data, outfile_name = "failed_check_data"){
  if (class(data) == "list"){
    # try casting each table to data.frame per requirement of writexl
    for (name in names(data)){
      if (nrow(data[[name]]) == 0){
        data[[name]] <- NULL
        next
      }
      
      data[[name]] <- as_data_frame(data[[name]])
    }
    
  }else{
    data <- as_data_frame(data)
  }

  write_xlsx(data, paste0(outfile_name, fileext = ".xlsx") )
}