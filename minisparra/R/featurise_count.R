#' Computes the number of rows per patient ID which contain specific values in
#' specific columns.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param spec A list containing the following elements:
#'  - source_file:         Filename of the source table to read from.
#'  - primary_filter:      A filter object to apply to the source table.
#'  - output_feature_name: Name of the output column.
#'  - grouping_columns:    Name of the column(s) to group by.
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
featurise_count <- function(all_tables,
                            spec,
                            context = NULL) {
  context <- c(context, "featurise_count")
  trace_context(context)

  # Validate spec
  source_table <- all_tables[[spec$source_file]]
  filter_obj <- spec$primary_filter
  output_feature_name <- spec$output_feature_name
  grouping_columns <- spec$grouping_columns
  missing_value <- spec$absent_data_flag

  if (length(grouping_columns) > 1) {
    stop("Multiple groupings not yet implemented")
  }

  # Calculate feature
  feature_table <- source_table %>%
    filter_all(filter_obj, context) %>%
    magrittr::extract2("passed") %>%
    rename(id = !!grouping_columns) %>%
    group_by(id) %>%
    summarise(!!output_feature_name := n())

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
