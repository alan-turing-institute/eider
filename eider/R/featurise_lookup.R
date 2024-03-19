#' Generates a feature which simply takes values from a named column from a
#' source table. If a patient has multiple rows in the source table, the
#' feature table will contain the value from the first row.
#'
#' @param all_tables List of all input tables (passed in from read_data).
#' @param spec A list containing the following elements:
#'  - source_file:         Filename of the source table to read from.
#'  - output_feature_name: Name of the output column.
#'  - grouping_column:     Name of the column to group by.
#'  - primary_filter:      A filter object to apply to the source table.
#'  - source_column_name:  Name of the column in the source table to look up
#'                         the feature value from.
#'  - absent_default_value:The value to use for patients who have no matching
#'                         rows in the source table.
#' @param context A character vector to be used in logging or error messages.
#' Defaults to NULL.
#'
#' @return A list with the following elements:
#' - feature_table: A data frame with one row per patient ID and one column
#'                  containing the desired value in the source table. The
#'                  column names are 'id' for the ID (this is standardised
#'                  across all feature tables), and the value of
#'                  output_feature_name.
#' - missing_value: The value to use for patients who have no matching rows in
#'                  the source table. This value is passed downstream to the
#'                  function which joins all the feature tables together.
featurise_lookup <- function(all_tables,
                             spec,
                             context = NULL) {
  context <- c(context, "featurise_lookup")
  trace_context(context)

  # Validate spec
  source_table <- validate_source_file(spec, all_tables, context)
  output_feature_name <- validate_output_feature_name(spec, context)
  grouping_column <- validate_column_present(
    "grouping_column", spec, source_table, context
  )
  source_column_name <- validate_column_present(
    "source_column_name", spec, source_table, context
  )
  trace_context(paste0("featurise_lookup applied to ",
                       source_column_name, " column"))
  missing_value <- validate_absent_default_value(spec, context)
  filter_obj <- spec$primary_filter

  # Calculate feature
  feature_table <- source_table %>% filter_all(filter_obj, context)
  feature_table <- tryCatch(
    {
      feature_table %>%
        magrittr::extract2("passed") %>%
        rename(id = !!grouping_column) %>%
        group_by(id) %>%
        summarise(
          !!output_feature_name := first(.data[[source_column_name]])
        ) %>%
        select(id, !!output_feature_name)
    },
    error = function(e) {
      error_context(e, context)
    }
  )

  # TODO: Verify that this is not needed. Logically, it shouldn't be
  feature_table <- pad_missing_values(
    source_table,
    grouping_column,
    missing_value,
    feature_table
  )

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
