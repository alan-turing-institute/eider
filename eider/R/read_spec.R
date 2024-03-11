#' Read spec type and give appropriate logging messages
#'
#' @param filename_or_json_str A string which may or may not be a valid filepath
#'
#' @return information if a file or a string has been provided
read_spec_type <- function(filename_or_json_str){
  trace_context("Checking for json file or str")
  result <- chk_pth(filename_or_json_str)
  if (result == "valid") {
    debug_context <- paste0("Valid filepath found ", filename_or_json_str)
    file_or_string <- "file"
  } else if (result=="too_long") {
    debug_context <-
    "Specified path is too long for a file, assuming a json string"
    file_or_string <- "string"
  } else if (result=="not_valid") {
    debug_context <-  "No valid filepath found, assuming a json string"
    file_or_string <- "string"
  } else if (result=="other_error") {
    stop("Unknown error when trying to read specification")
  }
  log_debug(debug_context)
  return(file_or_string)
}

#' Check to see if provided spec is path or a JSON string.
#'
#' @param file_or_json A string corresponding to either a filepath containing
#' the specification, or the specification itself as a json string
#'
#' @return A string identifying if the file was found or not
chk_pth <- function(file_or_json){
  tryCatch(
    expr = {
      is_valid_file <- fs::is_file(file_or_json)
      if (is_valid_file) {
        return("valid")
      } else {
        return("not_valid")
      }
    },
    error = function(e){
      too_long <- stringr::str_detect(e[[1]],"NAMETOOLONG")
      if (too_long) {
        return("too_long")
      } else {
        return("other_error")
      }
    }   )    }
