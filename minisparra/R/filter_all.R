#' Pass table through any type of filter.
#' 
#' @param table A table to filter.
#' @param filter_obj A filter to apply to the table. This is a list
#'  which can have 'type' = any of 'basic', 'or', 'and', or 'not'.
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_all <- function(table, filter_obj) {
  if (filter_obj$type == "in") {
    filter_results <- filter_in(table, filter_obj)
  } else if (filter_obj$type == "less_than") {
    filter_results <- filter_less_than(table, filter_obj)
  } else if (filter_obj$type == "less_than_equal") {
    filter_results <- filter_less_than_equal(table, filter_obj)
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
