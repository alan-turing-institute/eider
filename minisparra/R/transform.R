#' Perform the entire feature transformation process.
#'
#' @param data_sources A list mapping unique table identifiers to either
#' the file path from which they should be read from, or the data frame itself.
#' @param all_feature_json_filenames A vector of file paths to the feature JSON
#' specifications.
#'
#' @return A data frame with the feature tables joined together
#' @export
transform <- function(data_sources, all_feature_json_filenames) {
  # Read all the tables
  all_tables <- read_data(data_sources)

  # Read in each feature JSON file and calculate each individual feature
  features <- lapply(
    all_feature_json_filenames,
    function(json_fname) featurise(all_tables, json_fname)
  )

  # Join all the features together
  join_feature_tables(features)
}
