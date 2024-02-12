#' Filter table rows based on a comparison to a given value. All rows with a value
#' less than the given value are included in the result. The comparison is
#' exclusive i.e. rows with exactly this value are not included in the result.
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'less_than'
#'               - column: the name of the column to filter on
#'               - value: the threshold to filter on
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_less_than <- function(table, filter_obj) {
  if (filter_obj$type != "less_than") {
    stop("Filter type must be 'less_than'")
  }

  if (!filter_obj$column %in% colnames(table)) {
    stop("Column not found in table")
  }

  # Add a sentinel column indicating whether the row passed the filter
  table <- table %>%
    mutate(SPARRA_PRIVATE_FILTERED = .data[[filter_obj$column]] < filter_obj$value)

  # Split the table into passed and rejected rows, and remove the sentinel column
  list(
    passed = table %>%
      filter(SPARRA_PRIVATE_FILTERED) %>%
      select(-SPARRA_PRIVATE_FILTERED),
    rejected = table %>%
      filter(!SPARRA_PRIVATE_FILTERED) %>%
      select(-SPARRA_PRIVATE_FILTERED)
  )
}
