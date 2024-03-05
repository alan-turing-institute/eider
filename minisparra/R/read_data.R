#' Process the list of tables given, returning a list of tibbles. Each entry in
#' the list can either be a tibble itself (or a data.frame), or a string, in
#' which case it is assumed to be a file and is read in.
#'
#' @param filenames A vector of strings or dataframe-like objects.
#' @return A list of data frames. The names of the list are the same as the
#' names of the input list.
#' @export
read_data <- function(source_names) {
  purrr::imap(source_names, read_one_table)
}

#' Helper function to read a single table from a file.
read_one_table <- function(filepath_or_df, name) {
  if (is.character(filepath_or_df)) {
    df <- read.csv(filepath_or_df, header = TRUE)
  } else if (is.data.frame(filepath_or_df)) {
    df <- filepath_or_df
  } else {
    stop(paste0("Data must be provided as a data frame or a string.,
      The data source ", name, " is of class ", class(filepath_or_df), "."))
  }

  df %>%
    coerce_dates() %>%
    tibble()
}
