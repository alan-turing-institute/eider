#' Perform the entire feature transformation process.
#'
#' @param data_sources A list mapping unique table identifiers to either
#' the file path from which they should be read from, or the data frame itself.
#' @param feature_filenames A vector of file paths to the feature JSON
#' specifications. Defaults to NULL.
#' @param response_filenames A vector of file paths to the feature JSON
#' specifications. Defaults to NULL.
#' @param all_ids A vector of all the unique identifiers that should be in the
#' final feature table. If not given, will generate a feature table containing
#' all unique identifiers found in input tables used by at least one feature.
#'
#' @return A data frame with the feature tables joined together
#' @export
transform <- function(
    data_sources,
    feature_filenames = NULL,
    response_filenames = NULL,
    all_ids = NULL) {
  # Read all the tables
  all_tables <- read_data(data_sources)

  # Read in each feature JSON file and calculate each individual feature
  features <- lapply(
    feature_filenames,
    function(f) {
      featurise_wrapper(f, TRUE, all_tables)
    }
  )
  responses <- lapply(
    response_filenames,
    function(f) {
      featurise_wrapper(f, FALSE, all_tables)
    }
  )

  # Join all of them together
  join_feature_tables(features, all_ids = all_ids)
}

featurise_wrapper <- function(json_fname, is_feature, all_tables) {
  json_context <- json_fname
  file_or_string <- read_spec_type(json_fname)
  if (file_or_string == "string") {
    json_context <- "User defined string"
  } else {
    json_context <- json_fname
  }
  featurise(
    all_tables,
    json_to_feature(json_fname),
    is_feature = is_feature,
    context = paste0("featurise: ", json_context)
  )
}
