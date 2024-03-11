#' Perform the entire feature transformation process.
#'
#' @param data_sources A list mapping unique table identifiers to either
#' the file path from which they should be read from, or the data frame itself.
#' @param feature_filenames A vector of file paths to the feature JSON
#' specifications.
#'
#' @return A data frame with the feature tables joined together
#' @export
transform <- function(data_sources, feature_filenames) {
  # Read all the tables
  all_tables <- read_data(data_sources)

  # Check if file or json string provided
  file_or_string <- read_spec_type(feature_filenames)

  # Read in each feature JSON file and calculate each individual feature
  features <- lapply(
    feature_filenames,
    function(json_fname) {
      if (file_or_string == "string") {
        json_context <- "User defined string"
      } else {
        json_context <- json_fname
      }
      featurise(
        all_tables,
        json_to_feature(json_fname),
        context = paste0("featurise: ", json_context)
      )
    }
  )

  # Join all the features together
  join_feature_tables(features)
}
