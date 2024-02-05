#' Define an s3 class
tmp_class <- function(name, data_source, type, filter = NULL) {
  list(name = name, data_source = data_source, type = type, filter = filter)
}
attr(tmp_class, "class") <- "tmp_class"

#' Parses the specification json file into a Reference Class object
#'
#' @param filename
#'
#' @return
#' @export
#'
#' @examples
json_to_feature <- function(filename){
  json_data <- jsonlite::fromJSON(filename)
  print(json_data)
}
