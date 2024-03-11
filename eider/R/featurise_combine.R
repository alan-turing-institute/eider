#' Computes the combination of two or more features.
#'
#' @param mode 'linear' for linear combination of features, 'min' to take the
#'             minimum of the features, 'max' to take the maximum of the
#'             features.
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
featurise_combine <- function(mode,
                              all_tables,
                              spec,
                              context = NULL) {
  context <- c(context, paste0("featurise_combine:", mode))
  trace_context(context)

  mode <- tolower(mode)

  # featurise.R should already check this, so we use stop() instead of
  # error_context() here
  if (!mode %in% c("combine_linear", "combine_min", "combine_max")) {
    stop("Invalid combination mode: ", mode)
  }

  # Validate spec
  output_feature_name <- validate_output_feature_name(spec, context)

  # Choose starting missing value
  initial_missing_value <- switch(mode,
    combine_linear = 0,
    combine_min = Inf,
    combine_max = -Inf
  )
  missing_value <- initial_missing_value

  # Loop over subfeatures
  n <- length(spec$feature_list)
  subfeatures <- list()
  for (i in seq_along(spec$feature_list)) {
    subfeature_name <- names(spec$feature_list)[i]

    # Pass in the output feature name from the parent spec
    subfeature_spec <- spec$feature_list[[i]]
    subfeature_spec$output_feature_name <- subfeature_name

    # Update the missing value
    missing_value <- switch(mode,
      combine_linear = missing_value +
        (subfeature_spec$weight * subfeature_spec$absent_default_value),
      combine_min = min(missing_value, subfeature_spec$absent_default_value),
      combine_max = max(missing_value, subfeature_spec$absent_default_value)
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
  joined_subfeatures <- join_feature_tables(subfeatures, context = context)

  # Then combine the subfeatures
  feature_table <- tibble(id = joined_subfeatures$id) %>%
    mutate(!!output_feature_name := initial_missing_value)
  for (i in seq_along(subfeatures)) {
    subfeature_name <- names(spec$feature_list)[i]
    weight <- spec$feature_list[[i]]$weight
    feature_table[[output_feature_name]] <- switch(mode,
      combine_linear = feature_table[[output_feature_name]] +
        (weight * joined_subfeatures[[subfeature_name]]),
      combine_min = pmin(
        feature_table[[output_feature_name]],
        joined_subfeatures[[subfeature_name]]
      ),
      combine_max = pmax(
        feature_table[[output_feature_name]],
        joined_subfeatures[[subfeature_name]]
      )
    )
  }

  list(
    feature_table = tibble(feature_table),
    missing_value = missing_value
  )
}
