#' Filter table rows based on a comparison to a given value. All rows with a value
#' less than or equal to the given value are included in the result.
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'less_than_equal'
#'               - column: the name of the column to filter on
#'               - value: the threshold to filter on
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_less_than_equal <- function(table, filter_obj) {
  if (filter_obj$type != "less_than_equal") {
    stop("Filter type must be 'less_than_equal'")
  }

  if (!filter_obj$column %in% colnames(table)) {
    stop("Column not found in table")
  }

  # Add a sentinel column indicating whether the row passed the filter
  table <- table %>%
    mutate(SPARRA_PRIVATE_FILTERED = .data[[filter_obj$column]] <= filter_obj$value)

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
