#' Pass table through any type of filter.
#'
#' @param table A table to filter.
#' @param filter_obj A filter to apply to the table.
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_all <- function(table, filter_obj) {
  t <- filter_obj$type
  if (is.null(t)) {
    # Filter type was not found. Assuming no filtering desired
    # TODO: Log this
    return(list(passed = table, rejected = data.frame()))
  }

  if (t %in% c("IN", "LT", "LT_EQ", "GT", "GT_EQ")) {
    filter_results <- filter_basic(table, filter_obj)
  } else if (t == "OR") {
    filter_results <- filter_or(table, filter_obj)
  } else if (t == "AND") {
    filter_results <- filter_and(table, filter_obj)
  } else if (t == "NOT") {
    filter_results <- filter_not(table, filter_obj)
  } else {
    stop(paste("Filter type '", filter_obj$type, "' not implemented."))
  }
  filter_results
}
