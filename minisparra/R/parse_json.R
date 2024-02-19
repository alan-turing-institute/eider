#' Check if a filter is nested or single
#'
#' @param filter A filter as defined in the origin json file
#'
#' @return TRUE if the filter is nested, FALSE if it is not
#' @export
check_for_nested <- function(filter) {
  # For a given filter, check to see if it is nested or not
  # Return TRUE if it is nested, FALSE if it is not
  if (is.null(filter$subfilters)) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

#' Parse the header information from the json file to our targed feature object
#'
#' @param feature_object The R object which will define the filtering
#' @param json_data The parsed json data
#'
#' @return A feature object
#' @export
parse_header_info <- function(feature_object, json_data) {
  feature_object$source_file <- json_data$source_file
  feature_object$transformation_type <- json_data$transformation_type
  feature_object$primary_filter <- parse_single_or_nested(
    json_data$primary_filter
  )
  return(feature_object)
}

#' Parse a single (un-nested) filter and return a list with data column name
#' filter type, and the limiting values
#'
#' @param filter A filter as defined in the origin json file
#'
#' @return A filter object
#' @export
parse_single_filter <- function(filter) {
  print("Parsing single filter")
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
#' @export
parse_nested_filter <- function(nested_filter) {
  print("Parsing nested filter")
  op_nested_filter <- list()
  op_nested_filter$type <- nested_filter$type
  for (i in seq_along(nested_filter$subfilters)) {
    target <- nested_filter$subfilters[[i]]
    op_nested_filter$subfilters[[i]] <- parse_single_or_nested(target)
  }
  return(op_nested_filter)
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
  parse_header_info(list(), json_data)
}
