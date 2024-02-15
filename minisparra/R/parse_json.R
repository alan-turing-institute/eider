#' Check if a filter is nested or single
#'
#' @param filter A filter as defined in the origin json file
#'
#' @return
#' @export
#'
#' @examples
check_for_nested <- function(filter) {
  # For a given filter, check to see if it is nested or not
  # Return TRUE if it is nested, FALSE if it is not
  if (is.null(filter$filter)) {
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
#' @return
#' @export
#'
#' @examples
parse_header_info <- function(feature_object, json_data){
  feature_object$source_file <- json_data$source_file
  feature_object$transformation_type <- json_data$transformation_type
  feature_object$primary_filter <- list()
  feature_object$primary_filter$type <- json_data$primary_filter$type
  feature_object$primary_filter$filter <- list()
  return(feature_object)
}

#' Parse a single (un-nested) filter and return a list with data column name
#' filter type, and the limiting values
#'
#' @param filter A filter as defined in the origin json file
#'
#' @return
#' @export
#'
#' @examples
parse_single_filter <- function(filter){
  print("Parsing single filter")
  parsed_single_filter <- list()
  parsed_single_filter$data_column_name <- filter$data_column_name
  parsed_single_filter$type <- filter$type
  parsed_single_filter$values <- filter$values
  return(parsed_single_filter)
}

#' Parse a nested filter, returns a list of type (AND/OR) followed by lists
#' of the singular filters
#'
#' @param nested_filter A nested filter as defined in the origin json file
#'
#' @return
#' @export
#'
#' @examples
parse_nested_filter <- function(nested_filter){
  print("Parsing nested filter")
  op_nested_filter <- list()
  op_nested_filter$type <- nested_filter$type
  for (name in names(nested_filter$filter)) {
    target = nested_filter$filter[[name]]
    parsed_single_filter <- parse_single_filter(target)
    op_nested_filter$filter[[name]] <- parsed_single_filter
  }
  return(op_nested_filter)
}

#' Take the json input file and produce a formatted R object which can direct
#' the filters
#'
#' @param filename The relative filepath to the json file
#'
#' @return
#' @export
#'
#' @examples
json_to_feature <- function(filename){
  json_data <- jsonlite::fromJSON(filename)

  feature_object <- list()
  feature_object <- parse_header_info(feature_object, json_data)

  # Loop through all the keys in the selected filter
  for (key in names(json_data$primary_filter)) {
    if (key=="filter") {
      for (name in names(json_data$primary_filter$filter)) {
        # Check to see if the subfilters from the primary filter are nested or not
        target = json_data$primary_filter$filter[[name]]
        subfilt <- check_for_nested(target)
        if (subfilt) {
          parsed_nested_filter <- parse_nested_filter(target)
          feature_object$primary_filter$filter[[name]] <- parsed_nested_filter
        } else {
          parsed_single_filter <- parse_single_filter(target)
          feature_object$primary_filter$filter[[name]] <- parsed_single_filter
        }
      }
    }
  }
  return(feature_object)
}

