#' Check if a filter is nested or single
#'
#' @param filter A filter as defined in the origin json file
#'
#' @return TRUE if the filter is nested (as determined by it having the
#' 'subfilters' key), FALSE if it is not
check_for_nested <- function(filter) {
  !is.null(filter$subfilters)
}

parse_feature <- function(json_data) {
  if (json_data$transformation_type == "COMBINE") {
    # Handle COMBINE features separately
    feature_object <- list()
    feature_object$transformation_type <- json_data$transformation_type
    feature_object$output_feature_name <- json_data$output_feature_name
    feature_object$grouping_columns <- json_data$grouping_columns
    feature_object$feature_list <- list()
    for (i in seq_along(json_data$feature_list)) {
      feature_name <- names(json_data$feature_list)[[i]]
      feature <- parse_feature(json_data$feature_list[[i]])
      feature_object$feature_list[[feature_name]] <- feature
    }
    feature_object
  } else {
    parse_single_feature(json_data)
  }
}

#' Parse the header information from the json file to our targed feature object
#'
#' @param json_data The parsed json data
#'
#' @return A feature object
parse_single_feature <- function(json_data) {
  # Initialise empty list
  feature_object <- list()

  # Read in all keys, using the special filter parser for the "primary_filter"
  # key
  for (key in names(json_data)) {
    if (key == "primary_filter") {
      feature_object$primary_filter <- parse_single_or_nested(
        json_data$primary_filter
      )
    } else {
      feature_object[[key]] <- json_data[[key]]
    }
  }
  feature_object
}

# TODO - when parsing header check that only COUNT is allowed to exist without
# an aggreation column
# TODO set a log warning/info level that the absent data flag is set to
# whatever user has specified
# TODO - put in a warning if expected/mandatory flags are missing

#' Parse a single (un-nested) filter and return a list with data column name
#' filter type, and the limiting values
#'
#' @param filter A filter as defined in the origin json file
#'
#' @return A filter object
parse_single_filter <- function(filter) {
  log_debug("Parsing single filter")
  parsed_single_filter <- list()
  parsed_single_filter$column <- filter$column
  parsed_single_filter$type <- filter$type
  parsed_single_filter$value <- filter$value
  return(parsed_single_filter)
}

#' Parse a nested filter, returns a list of type (AND/OR) followed by lists
#' of the singular filters
#'
#' @param nested_filter A nested filter as defined in the origin json file
#'
#' @return A nested filter object
parse_nested_filter <- function(nested_filter) {
  log_debug("Parsing nested filter")
  op_nested_filter <- list()
  op_nested_filter$type <- nested_filter$type
  op_nested_filter$subfilters <- list()
  for (nm in names(nested_filter$subfilters)) {
    target <- nested_filter$subfilters[[nm]]
    op_nested_filter$subfilters[[nm]] <- parse_single_or_nested(target)
  }
  op_nested_filter
}

#' Check if a filter is nested or single and parse accordingly
parse_single_or_nested <- function(filter) {
  if (check_for_nested(filter)) {
    parse_nested_filter(filter)
  } else {
    parse_single_filter(filter)
  }
}

#' Take the json input file and produce a formatted R object which can direct
#' the filters
#'
#' @param filename The relative filepath to the json file
#'
#' @return A feature object
#' @export
json_to_feature <- function(filename) {
  json_data <- jsonlite::fromJSON(filename)
  parse_single_feature(json_data)
}
