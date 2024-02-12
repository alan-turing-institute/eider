#' Pass table through any type of filter.
#'
#' @param table A table to filter.
#' @param filter_obj A filter to apply to the table.
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_all <- function(table, filter_obj) {
  if (filter_obj$type %in% c("in", "less_than", "less_than_equal", "greater_than", "greater_than_equal")) {
    filter_results <- filter_basic(table, filter_obj)
  } else if (filter_obj$type == "or") {
    filter_results <- filter_or(table, filter_obj)
  } else if (filter_obj$type == "and") {
    filter_results <- filter_and(table, filter_obj)
  } else if (filter_obj$type == "not") {
    filter_results <- filter_not(table, filter_obj)
  } else {
    stop(paste("Filter type '", filter_obj$type, "' not implemented."))
  }
  filter_results
}
