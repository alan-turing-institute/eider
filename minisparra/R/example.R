#' Return path to the example datasets provided with the package
#'
#' @param file Name of the file to be used from inst/extdata.
#' If NULL all files will be listed
#'
#' @return
#' @export
#'
#' @examples
#' minisparra_example() Returns a list of all the random patient data
#' minisparra_example("random_ae_data.csv") Returns path to the random
#' A&E type file
minisparra_example <- function(file = NULL) {
  current_package_name <- "miniSPARRA01"
  if (is.null(file)) {
    dir(system.file("extdata", package = current_package_name))
  } else {
    system.file("extdata",
                file,
                package = current_package_name,
                mustWork = TRUE)
  }
}
