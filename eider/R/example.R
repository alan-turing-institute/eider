#' Return path to the example datasets provided with the package
#'
#' @param file Name of the file to be used from inst/extdata.
#' If NULL all files will be listed
#'
#' @return A character string with the path to the file, or a vector of strings
#' @export
#'
#' @examples
#' eider_example()
#' eider_example("random_ae_data.csv")
eider_example <- function(file = NULL) {
  current_package_name <- "eider"
  if (is.null(file)) {
    dir(system.file("extdata", package = current_package_name))
  } else {
    system.file("extdata",
      file,
      package = current_package_name,
      mustWork = TRUE
    )
  }
}
