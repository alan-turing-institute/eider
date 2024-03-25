#' Adjust date formats to DD-MM-YYYY
#'
#' @export
adjust_date_format <- function(dx) {
  for (i in seq_len(dim(dx)[2])) {
    if (class(dx[1, i]) == "Date") {
      dx[, i] <- format(dx[, i], "%d-%m-%Y")
    }
  }
  dx
}

# Get dictionary key by value
get_key <- function(dict, value) {
  keys <- names(dict)
  for (key in keys) {
    if (dict[[key]] == value) {
      return(key)
    }
  }
  return(NULL)
}

# Get dictionary value by key
get_value <- function(dict, key) {
  return(dict[[key]])
}
