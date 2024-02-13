#' Groups by ID and computes the sum of the values in all rows which pass a
#' given filter.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param source_table_file Filename of the source table to read from.
#' @param filter_obj A filter object to apply to the source table.
#' @param column_to_sum_name Name of the column which provides the values to be
#' summed.
#' @param id_column_name Name of the patient ID column in the source table.
#' Defaults to 'id'.
#' @param missing_value The value to use for patients who have no matching rows
#' in the source table. Defaults to 0.
#' @param output_column_name Name of the output column.
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
featurise_sum <- function(all_tables,
                          source_table_file,
                          filter_obj,
                          column_to_sum_name,
                          id_column_name = "id",
                          missing_value = 0,
                          output_column_name) {
  source_table <- all_tables[[source_table_file]]

  feature_table <- source_table %>%
    filter_all(filter_obj) %>%
    magrittr::extract2("passed") %>%
    group_by(.data[[id_column_name]]) %>%
    rename(id = !!id_column_name) %>%
    summarise(!!output_column_name := sum(.data[[column_to_sum_name]]))

  list(
    feature_table = feature_table,
    output_column_name = output_column_name,
    missing_value = missing_value
  )
}
