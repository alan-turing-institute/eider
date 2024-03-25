#' Extract a feature table using a feature JSON file.
#'
#' @param all_tables List of all input tables (passed in from read_data).
#' @param spec Parsed JSON file containing the feature specification.
#' @param is_feature Logical indicating whether the feature is a feature (TRUE)
#' or a response (FALSE). Defaults to TRUE.
#' @param context A character vector to be used in logging or error messages.
#' Defaults to NULL.
#'
#' @return A list with the following elements:
#' - feature_table: A data frame with one row per patient ID and one column
#'                  containing the sum of matching rows in the source table.
#'                  The column names are 'id' for the ID (this is standardised
#'                  across all feature tables), and the value of
#'                  output_column_name.
#' - is_feature:    Logical indicating whether the feature is a feature (TRUE)
#'                  or a response (FALSE).
#' - missing_value: The value to use for patients who have no matching rows in
#'                  the source table. This value is passed downstream to the
#'                  function which joins all the feature tables together.
#' @export
featurise <- function(all_tables,
                      spec,
                      is_feature = TRUE,
                      context = NULL) {
  trace_context(context)

  # Read the feature JSON file
  t <- spec$transformation_type %>% tolower()

  # If the preprocessing flag exists in the spec update the corresponding table
  if (exists("preprocess", spec)) {
    log_trace(paste("Table", spec$source_file, "will be preprocessed"))
    updated_table <- preprocess_table(
      input_table = all_tables[[spec$source_file]],
      spec = spec
    )
    all_tables[[spec$source_file]] <- updated_table
  }
  # Check the transformation type and dispatch to the appropriate function
  if (t == "count") {
    feature <- featurise_count(all_tables, spec, context)
  } else if (t == "sum") {
    feature <- featurise_sum(all_tables, spec, context)
  } else if (t == "lookup") {
    feature <- featurise_lookup(all_tables, spec, context)
  } else if (t == "present") {
    feature <- featurise_present(all_tables, spec, context)
  } else if (t == "nunique") {
    feature <- featurise_unique(all_tables, spec, context)
  } else if (t == "time_since") {
    feature <- featurise_time_since(all_tables, spec, context)
  } else if (t %in% c("combine_linear", "combine_min", "combine_max")) {
    feature <- featurise_combine(mode = t, all_tables, spec, context)
  } else {
    stop_context(
      context = context,
      message = paste0("Unknown transformation type: ", t),
    )
  }

  feature$is_feature <- is_feature  # Used by join_feature_tables
  feature
}
