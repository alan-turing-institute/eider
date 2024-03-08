#' Generates a feature which, for each patient ID, contains a 1 if any row that
#' passes a specified filter exists, or 0 if not.
#'
#' @param all_tables List of all input tables (passed in from read_data).
#' @param spec A list containing the following elements:
#'  - source_file:         Filename of the source table to read from.
#'  - primary_filter:      A filter object to apply to the source table.
#'  - output_feature_name: Name of the output column.
#'  - grouping_columns:    Name of the column(s) to group by.
#' @param context A character vector to be used in logging or error messages.
#' Defaults to NULL.
#'
#' @return A list with the following elements:
#' - feature_table: A data frame with a 1 or 0 in the output column for each
#'                  patient ID, depending on whether any rows in the source
#'                  table pass the filter.
#' - missing_value: The value to use for patients who have no matching rows in
#'                  the source table. This value is passed downstream to the
#'                  function which joins all the feature tables together. By
#'                  definition, this value is 0.
featurise_present <- function(all_tables,
                              spec,
                              context = NULL) {
  context <- c(context, "featurise_present")
  trace_context(context)

  # Validate spec
  source_table <- all_tables[[spec$source_file]]
  filter_obj <- spec$primary_filter
  output_feature_name <- spec$output_feature_name
  grouping_columns <- spec$grouping_columns
  missing_value <- 0

  if (length(grouping_columns) > 1) {
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
        summarise(!!output_feature_name := 1)
    },
    error = function(e) {
      error_context(e, context)
    }
  )

  feature_table <- pad_missing_values(
    source_table,
    grouping_columns,
    missing_value,
    feature_table
  )

  list(
    feature_table = feature_table,
    missing_value = missing_value
  )
}
