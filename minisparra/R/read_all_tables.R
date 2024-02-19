#' Read in all tables from a list of filenames.
#'
#' @param filenames A vector of filenames.
#' @return A list of data frames.
#' @export
read_all_tables <- function(filenames) {
  tables <- lapply(filenames, read_one_table)
  names(tables) <- filenames
  tables
}

#' Helper function to read a singlet able.
#'
#' @export
read_one_table <- function(filename) {
  filename %>%
    read.csv(header = TRUE) %>%
    coerce_dates()
}
