#' Generic function for a basic filter, parametrised over the type of
#' comparison operator used to select rows.
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'in', 'less_than', 'less_than_equal',
#'                      'greater_than', or 'greater_than_equal'
#'               - column: the name of the column to filter on
#'               - value: a vector of values to filter on (for type 'in'), or
#'                 a single value (for all other types)
#' @param context A string to be used in logging or error messages. Defaults to
#' NULL.
#'
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
filter_basic <- function(table,
                         filter_obj,
                         context = NULL) {
  context <- c(context, "filter_basic")
  trace_context(context)

  valid_filter_types <- c("IN", "LT", "LT_EQ", "GT", "GT_EQ")
  if (!(filter_obj$type %in% valid_filter_types)) {
    stop("Filter type must be one of ", valid_filter_types)
  }

  if (!filter_obj$column %in% colnames(table)) {
    stop("Column not found in table")
  }

  # Choose the appropriate comparison operator
  operator <- switch(filter_obj$type,
    "IN" = `%in%`,
    "LT" = `<`,
    "LT_EQ" = `<=`,
    "GT" = `>`,
    "GT_EQ" = `>=`
  )

  # Add a sentinel column indicating whether the row passed the filter
  table <- table %>%
    mutate(
      SPARRA_PRIVATE_FILTERED =
        operator(.data[[filter_obj$column]], filter_obj$value)
    )

  # Split the table into passed and rejected rows, and remove the sentinel
  # column
  list(
    passed = table %>%
      filter(SPARRA_PRIVATE_FILTERED) %>%
      select(-SPARRA_PRIVATE_FILTERED),
    rejected = table %>%
      filter(!SPARRA_PRIVATE_FILTERED) %>%
      select(-SPARRA_PRIVATE_FILTERED)
  )
}
