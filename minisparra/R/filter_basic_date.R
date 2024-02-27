#' Generic function for a basic filter, parametrised over the type of
#' comparison operator used to select rows. The values to be taken are
#' dates instead of numbers, though.
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'date_in', 'date_lt', 'date_lt_eq', 'date_gt',
#'                       or 'date_gt_eq' (case-insensitive)
#'               - column: the name of the column to filter on
#'               - value: a vector of values to filter on (for type 'in'), or
#'                 a single value (for all other types)
#' @param context A string to be used in logging or error messages. Defaults to
#' NULL.
#'
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
filter_basic_date <- function(table,
                              filter_obj,
                              context = NULL) {
  context <- c(context, "filter_basic_date")
  trace_context(context)

  t <- tolower(filter_obj$type)
  valid_filter_types <- c(
    "date_in", "date_lt",
    "date_lt_eq", "date_gt", "date_gt_eq"
  )
  if (!(t %in% valid_filter_types)) {
    error_context(
      paste0(
        "Expected filter type to be one of ",
        paste(
          sapply(valid_filter_types, function(x) paste0("'", x, "'")),
          collapse = ", "
        ),
        ", but got '", filter_obj$type, "'."
      ),
      context
    )
  }

  if (!filter_obj$column %in% colnames(table)) {
    error_context(
      paste0("Column '", filter_obj$column, "' not found in the table."),
      context
    )
  }

  # Choose the appropriate comparison operator
  operator <- switch(t,
    "date_in" = `%in%`,
    "date_lt" = `<`,
    "date_lt_eq" = `<=`,
    "date_gt" = `>`,
    "date_gt_eq" = `>=`
  )

  # Add a sentinel column indicating whether the row passed the filter
  table <- table %>%
    mutate(
      SPARRA_PRIVATE_FILTERED =
        operator(.data[[filter_obj$column]], lubridate::ymd(filter_obj$value))
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
