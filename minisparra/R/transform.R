#' Perform the entire feature transformation process.
#'
#' @param all_table_filenames A vector of file paths to the source tables.
#' @param all_feature_json_filenames A vector of file paths to the feature JSON
#' specifications.
#'
#' @return A data frame with the feature tables joined together
#' @export
transform <- function(all_table_filenames, all_feature_json_filenames) {
  # Read all the tables
  all_tables <- read_all_tables(all_table_filenames)

  # Read in each feature JSON file and calculate each individual feature
  features <- lapply(
    all_feature_json_filenames,
    function(json_fname) {
      featurise(
        all_tables,
        json_to_feature(json_fname),
        context = paste0("featurise: ", json_fname)
      )
    }
  )

  # Join all the features together
  join_feature_tables(features)
}
