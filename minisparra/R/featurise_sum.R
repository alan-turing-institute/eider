#' Groups by ID and computes the sum of the values in all rows which pass a
#' given filter.
#'
#' @param all_tables List of all input tables (passed in from read_data).
#' @param spec A list containing the following elements:
#'  - source_file:         Filename of the source table to read from.
#'  - primary_filter:      A filter object to apply to the source table.
#'  - aggregation_column:  Name of the column which provides the values to be
#'  -                      summed over.
#'  - output_feature_name: Name of the output column.
#'  - grouping_columns:    Name of the columns to group the source table by
#'                         before summation.
#'  - absent_data_flag:    The value to use for patients who have no matching
#'                         rows in the source table.
#' @param context A character vector to be used in logging or error messages.
#' Defaults to NULL.
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
featurise_sum <- function(all_tables,
                          spec,
                          context = NULL) {
  context <- c(context, "featurise_sum")
  trace_context(context)

  # Validate spec
  source_table <- all_tables[[spec$source_file]]
  filter_obj <- spec$primary_filter
  output_feature_name <- spec$output_feature_name
  column_to_sum_over <- spec$aggregation_column
  grouping_columns <- spec$grouping_columns
  missing_value <- spec$absent_data_flag

  if (length(grouping_columns) > 1) {
    # TODO: Issue #24
    stop("Multiple groupings not yet implemented")
  }

  # Calculate feature
  feature_table <- source_table %>% filter_all(filter_obj, context)
  feature_table <- tryCatch(
    {
      feature_table %>%
        magrittr::extract2("passed") %>%
        rename(id = !!grouping_columns) %>%
        group_by(id) %>%
        summarise(!!output_feature_name := sum(.data[[column_to_sum_over]]))
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
