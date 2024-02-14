#' Computes the number of rows per patient ID which contain specific values in
#' specific columns.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param source_table_file Filename of the source table to read from.
#' @param filter_obj A filter object to apply to the source table.
#' @param id_column_name Name of the patient ID column in the source table.
#' @param missing_value The value to use for patients who have no matching rows
#' in the source table.
#' @param output_column_name Name of the output column.
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
featurise_count <- function(all_tables,
                            source_table_file,
                            filter_obj,
                            id_column_name = "id",
                            missing_value = 0,
                            output_column_name) {
  source_table <- all_tables[[source_table_file]]

  feature_table <- source_table %>%
    filter_all(filter_obj) %>%
    magrittr::extract2("passed") %>%
    group_by(.data[[id_column_name]]) %>%
    rename(id = !!id_column_name) %>%
    summarise(!!output_column_name := n())

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
