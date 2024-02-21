#' First passes a table through a filter, then counts the time between a given
#' date and the first OR last date in the filtered table.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param source_table_file Filename of the source table to read from.
#' @param filter_obj A filter object to apply to the source table.
#' @param date_column_name Name of the date column in the source table to
#' calculate the time since.
#' @param cutoff_date The date to calculate the time since from.
#' @param from_first If TRUE, calculate the time since the first date in the
#' filtered table. If FALSE, calculate the time since the last (most recent)
#' date in the filtered table.
#' @param time_units Either "days" or "years". The number of years is defined as
#' the number of full 365.25 day periods between the two dates (and is rounded
#' down to the nearest whole number).
#' @param output_column_name Name of the output column.
#' @param id_column_name Name of the patient ID column in the source table.
#' Defaults to 'id'.
#' @param missing_value The value to use for patients who have no matching rows
#' in the source table. Defaults to 0.
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
#' @export
featurise_time_since <- function(all_tables,
                                 source_table_file,
                                 filter_obj,
                                 date_column_name,
                                 cutoff_date,
                                 from_first,
                                 time_units,
                                 output_column_name,
                                 id_column_name = "id",
                                 missing_value = 0) {
  source_table <- all_tables[[source_table_file]]

  cutoff_date <- lubridate::ymd(cutoff_date)

  feature_table <- source_table %>%
    filter_all(filter_obj) %>%
    magrittr::extract2("passed") %>%
    rename(id = !!id_column_name)

  if (time_units == "years") {
    ndays <- lubridate::ddays(365.25)
  } else if (time_units == "days") {
    ndays <- lubridate::ddays(1)
  } else {
    stop("time_units must be either 'days' or 'years'")
  }

  feature_table <- feature_table %>%
    mutate(
      !!output_column_name :=
        (cutoff_date - .data[[date_column_name]]) %/% ndays
    ) %>%
    group_by(id)

  if (from_first) {
    feature_table <- feature_table %>%
      summarise(!!output_column_name := max(.data[[output_column_name]]))
  } else {
    feature_table <- feature_table %>%
      summarise(!!output_column_name := min(.data[[output_column_name]]))
  }

  feature_table <- feature_table %>% select(id, !!output_column_name)

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
