#' Coerce YYYYMMDD columns in a data frame to dates where possible, using
#' lubridate::ymd. This function only converts columns where every value
#' successfully coerces to a date.
#'
#' @param table A data frame
#' @return A data frame with columns coerced to dates where possible
coerce_dates <- function(table) {
  cols <- names(table)

  for (col in cols) {
    maybe_dates <- lubridate::ymd(table[[col]], quiet = TRUE)
    if (!anyNA(maybe_dates)) {
      table[[col]] <- maybe_dates
    }
  }

  table
}
