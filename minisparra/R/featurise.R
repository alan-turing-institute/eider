#' Extract a feature table using a feature JSON file.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param feature_json_file Path to the feature JSON file.
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
#' @export
featurise <- function(all_tables,
                      feature_json_file,
                      context = NULL) {
  context <- c(context, paste0("featurise:", feature_json_file))
  trace_context(context)

  # Read the feature JSON file
  spec <- json_to_feature(feature_json_file)
  t <- spec$transformation_type %>% tolower()

  # Check the transformation type and dispatch to the appropriate function
  # TODO: validate fields
  if (t == "count") {
    feature <- featurise_count(all_tables, spec, context)
  } else if (t == "sum") {
    feature <- featurise_sum(all_tables, spec, context)
  } else if (t == "nunique") {
    feature <- featurise_unique(all_tables, spec, context)
  } else if (t == "time_since") {
    feature <- featurise_time_since(all_tables, spec, context)
  } else {
    stop("Unknown transformation type: ", t)
  }

  feature
}
