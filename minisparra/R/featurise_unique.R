#' Groups by ID, filters for rows that obey certain conditions, and computes
#' the number of unique values in a given column.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param source_table_file Filename of the source table to read from.
#' @param filter_obj A filter object to apply to the source table.
#' @param aggregate_column_name Name of the column over which to aggregate.
#' @param output_column_name Name of the output column.
#' @param id_column_name Name of the patient ID column in the source table.
#' Defaults to 'id'.
#' @param missing_value The value to use for patients who have no matching rows
#' in the source table. Defaults to 0.
#'
#' @return A list with the following elements:
#' - feature_table: A data frame with one row per patient ID and one column
#'                  containing the sum of matching rows in the source table.
#'                  The column names are 'id' for the ID (this is standardised
#'                  across all feature tables), and the value of
#'                  output_column_name.
#' - missing_value: The value to use for patients who have no matching rows in
#'                  the source table. This value is passed downstream to the
#'                  function which joins all the feature tables together.
#' @export
featurise_unique <- function(all_tables,
                             source_table_file,
                             filter_obj,
                             aggregate_column_name,
                             output_column_name,
                             id_column_name = "id",
                             missing_value = 0) {
  source_table <- all_tables[[source_table_file]]

  feature_table <- source_table %>%
    filter_all(filter_obj) %>%
    magrittr::extract2("passed") %>%
    rename(id = !!id_column_name) %>%
    group_by(id) %>%
    summarise(
      !!output_column_name := n_distinct(.data[[aggregate_column_name]])
    )

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
