#' Read in all tables from a list of filenames.
#' 
#' @param filenames A vector of filenames.
#' @return A list of data frames.
#' @export
read_all_tables <- function(filenames) {
  tables <- lapply(filenames, read.csv, header = TRUE)
  names(tables) <- filenames
  tables
}
