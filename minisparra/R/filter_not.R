#' Filter table rows based on a logical negation of a filter (i.e. NOT filter1)
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'not'
#'               - subfilter: a single filter object
#' @return A list with the following elements:
#'               - passed: data frame with the rows that satisfies the NOT
#'                         filter
#'               - rejected: all other rows
#' @export
filter_not <- function(table, filter_obj) {
  if (filter_obj$type != "NOT") {
    stop("Filter type must be 'NOT'")
  }

  subfilter_results <- filter_all(table, filter_obj)
  list(
    passed = subfilter_results$rejected,
    rejected = subfilter_results$passed
  )
}
