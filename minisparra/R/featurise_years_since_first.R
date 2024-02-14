#' Computes the number of years from the first entry in a source table
#' fulfilling a filter, to a given cutoff date. The number of years is defined
#' as the number of full 365.25 day periods between the two dates (i.e., it is
#' rounded down to the nearest whole number).
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param source_table_file Filename of the source table to read from.
#' @param filter_obj A filter object to apply to the source table.
#' @param date_column_name Name of the date column in the source table to
#' calculate the 'years since'.
#' @param cutoff_date The date to calculate the 'years since' from.
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
featurise_years_since_first <- function(all_tables,
                                        source_table_file,
                                        filter_obj,
                                        date_column_name,
                                        cutoff_date,
                                        output_column_name,
                                        id_column_name = "id",
                                        missing_value = 0) {
  source_table <- all_tables[[source_table_file]]

  cutoff_date <- lubridate::ymd(cutoff_date)

  feature_table <- source_table %>%
    filter_all(filter_obj) %>%
    magrittr::extract2("passed") %>%
    rename(id = !!id_column_name) %>%
    mutate(!!output_column_name := (cutoff_date - .data[[date_column_name]]) %/% lubridate::ddays(365.25)) %>%
    group_by(id) %>%
    summarise(!!output_column_name := max(.data[[output_column_name]])) %>%
    select(id, !!output_column_name)

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
