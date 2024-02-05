#' Filter table rows based on a single condition, i.e. a column having values
#' in a given set
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'basic'
#'               - column: the name of the column to filter on
#'               - values: a vector of values to filter on
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_basic <- function(table, filter_obj) {
  if (filter_obj$type != "basic") {
    stop("Filter type must be 'basic'")
  }

  if (!filter_obj$column %in% colnames(table)) {
    stop("Column not found in table")
  }

  # Add a sentinel column indicating whether the row passed the filter
  table <- table %>%
    mutate(SPARRA_PRIVATE_FILTERED = .data[[filter_obj$column]] %in% filter_obj$values)

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
