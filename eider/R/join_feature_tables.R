#' Join feature tables together.
#'
#' @param calculated_features A list of calculated features, each of which is
#' produced by the featurise_... functions
#' @param all_ids A vector of all the unique identifiers that should be in the
#' final feature table. If not given, will generate a feature table containing
#' all unique identifiers found in input tables used by at least one feature.
#' @param context A string to be used in logging or error messages. Defaults to
#' NULL.
#'
#' @return A data frame with the feature tables joined together
#' @export
join_feature_tables <- function(
    calculated_features,
    all_ids = NULL,
    context = NULL) {
  context <- c(context, "join_feature_tables")
  trace_context(context)

  if (length(calculated_features) == 0) {
    error_context("No feature tables to join.", context)
  }

  # If not supplied, collect the set of IDs across all tables
  if (is.null(all_ids)) {
    get_ids <- function(feature) feature$feature_table$id
    all_ids <- lapply(calculated_features, get_ids) %>%
      unlist() %>%
      unique() %>%
      sort()
  }
  df <- data.frame(id = all_ids)

  for (i in seq_along(calculated_features)) {
    feature <- calculated_features[[i]]
    feature_table <- feature$feature_table
    missing_value <- feature$missing_value
    output_column_name <- setdiff(names(feature$feature_table), "id")

    # Join the feature table to the main table and replace any NAs with the
    # specified missing value
    df <- df %>%
      left_join(feature_table, by = "id") %>%
      mutate(
        !!output_column_name :=
          coalesce(.data[[output_column_name]], missing_value)
      )
  }

  df
}
