#' First passes a table through a filter, then counts the time between a given
#' date and the first OR last date in the filtered table.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param spec A list containing the following elements:
#'  - source_file:         Filename of the source table to read from.
#'  - primary_filter:      A filter object to apply to the source table.
#'  - date_column:         Name of the date column in the source table to
#'                         calculate the time since.
#'  - cutoff_date:         The date to calculate the time since from.
#'  - from_first:          If TRUE, calculate the time since the first date in
#'                         the filtered table. If FALSE, calculate the time
#'                         since the last (most recent) date in the filtered
#'                         table.
#'  - time_units:          Either "days" or "years". The number of years is
#'                         defined as the number of full 365.25 day periods
#'                         between the two dates (and is rounded down to the
#'                         nearest whole number).
#'  - output_feature_name: Name of the output column.
#'  - grouping_columns:    Name of the columns in the source table over which
#'                         to group by.
#'  - absent_data_flag:    The value to use for patients who have no matching
#'                         rows in the source table.
#' @param context A character vector to be used in logging or error messages.
#' Defaults to NULL.
#'
#' @return A list with the following elements:
#' - feature_table: A data frame with one row per patient ID and one column
#'                  containing the count of matching rows in the source table.
#'                  The column names are 'id' for the ID (this is standardised
#'                  across all feature tables), and the value of
#'                  output_column_name.
#' - missing_value: The value to use for patients who have no matching rows in
#'                  the source table. This value is passed downstream to the
#'                  function which joins all the feature tables together.
featurise_time_since <- function(all_tables,
                                 spec,
                                 context = NULL) {
  context <- c(context, "featurise_time_since")
  trace_context(context)

  # Validate spec
  source_table <- all_tables[[spec$source_file]]
  filter_obj <- spec$primary_filter
  date_column <- spec$date_column
  cutoff_date <- lubridate::ymd(spec$cutoff_date)
  from_first <- spec$from_first
  time_units <- spec$time_units
  output_feature_name <- spec$output_feature_name
  grouping_columns <- spec$grouping_columns
  missing_value <- spec$absent_data_flag

  # Calculate feature
  feature_table <- source_table %>% filter_all(filter_obj, context)
  feature_table <- tryCatch(
    {
      feature_table %>%
        magrittr::extract2("passed") %>%
        rename(id = !!grouping_columns)
    },
    error = function(e) {
      error_context(e, context)
    }
  )

  if (time_units == "years") {
    ndays <- lubridate::ddays(365.25)
  } else if (time_units == "days") {
    ndays <- lubridate::ddays(1)
  } else {
    error_context("Time_units must be either 'days' or 'years'", context)
  }

  feature_table <- tryCatch(
    {
      tbl <- feature_table %>%
        mutate(
          !!output_feature_name :=
            (cutoff_date - .data[[date_column]]) %/% ndays
        ) %>%
        group_by(id)

      if (from_first) {
        tbl <- tbl %>%
          summarise(!!output_feature_name := max(.data[[output_feature_name]]))
      } else {
        tbl <- tbl %>%
          summarise(!!output_feature_name := min(.data[[output_feature_name]]))
      }
      tbl %>% select(id, !!output_feature_name)
    },
    error = function(e) {
      error_context(e, context)
    }
  )

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
