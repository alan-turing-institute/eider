#' Join feature tables together.
#'
#' @param calculated_features A list of calculated features, each of which is
#' produced by the featurise_... functions
#' @return A data frame with the feature tables joined together
#' @export
join_feature_tables <- function(calculated_features) {

  if (length(calculated_features) == 0) {
    stop("No feature tables to join")
  }

  # First collect the set of IDs across all tables
  get_ids <- function(feature) feature$feature_table$id
  all_ids <- lapply(calculated_features, get_ids) %>%
    unlist() %>%
    unique() %>%
    sort()
  df <- data.frame(id = all_ids)

  for (i in seq_along(calculated_features)) {
    feature <- calculated_features[[i]]
    feature_table <- feature$feature_table
    missing_value <- feature$missing_value
    output_column_name <- feature$output_column_name

    # Join the feature table to the main table and replace any NAs with the
    # specified missing value
    df <- df %>%
      left_join(feature_table, by = "id") %>%
      mutate(!!output_column_name := coalesce(.data[[output_column_name]], missing_value))
  }

  df
}
