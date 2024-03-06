#' Return path to the example datasets provided with the package
#'
#' @param file Name of the file to be used from inst/extdata.
#' If NULL all files will be listed
#'
#' @return
#' @export
#'
#' @examples
#' minisparra_example()
#' minisparra_example("random_ae_data.csv")
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
