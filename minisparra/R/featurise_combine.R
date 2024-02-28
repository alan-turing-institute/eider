#' Computes the linear combination of two or more features.
#'
#' @param all_tables List of all input tables (passed in from read_all_tables).
#' @param spec A list containing the following elements:
#'  - output_feature_name: Name of the output column.
#'  - grouping_columns:    Name of the column(s) to group by.
#'  - feature_list:        List of feature specs to combine.
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
featurise_combine <- function(all_tables,
                              spec,
                              context = NULL) {
  context <- c(context, "featurise_combine")
  trace_context(context)

  # Validate spec
  output_feature_name <- spec$output_feature_name
  grouping_columns <- spec$grouping_columns
  if (length(grouping_columns) > 1) {
    stop("Multiple groupings not yet implemented")
  }

  missing_value <- 0

  # Loop over subfeatures
  n <- length(spec$feature_list)
  subfeatures <- list()
  for (i in seq_along(spec$feature_list)) {
    subfeature_name <- names(spec$feature_list)[i]

    # Pass in the grouping columns and output feature name from the parent spec
    subfeature_spec <- spec$feature_list[[i]]
    subfeature_spec$grouping_columns <- grouping_columns
    subfeature_spec$output_feature_name <- subfeature_name

    # Add the appropriately weighted missing value
    missing_value <- missing_value + (
      subfeature_spec$weight * subfeature_spec$absent_data_flag
    )

    # Calculate the feature
    extra_ctx <- c(context, "(feature", i, "of", n, ": ", subfeature_name, ")")
    subfeatures[[i]] <- featurise(
      all_tables,
      subfeature_spec,
      c(context, extra_ctx)
    )
  }

  # Combine the subfeatures into a table
  joined_subfeatures <- join_feature_tables(subfeatures, context)

  # Then take a linear combination of the subfeatures
  feature_table <- tibble(id = joined_subfeatures$id) %>%
    mutate(!!output_feature_name := 0)
  for (i in seq_along(subfeatures)) {
    subfeature_name <- names(spec$feature_list)[i]
    weight <- spec$feature_list[[i]]$weight
    feature_table[[output_feature_name]] <-
      feature_table[[output_feature_name]] +
      weight * joined_subfeatures[[subfeature_name]]
  }

  list(
    feature_table = tibble(feature_table),
    missing_value = missing_value
  )
}
