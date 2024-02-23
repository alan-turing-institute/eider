#' Filter table rows based on a logical disjunction of multiple filters (i.e.
#' filter1 OR filter2 OR ...)
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'or'
#'               - subfilters: a list of filter objects
#' @param context A string to be used in logging or error messages. Defaults to
#' NULL.
#'
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
#' @export
filter_or <- function(table, filter_obj, context = NULL) {
  context <- c(context, "filter_or")
  trace_context(context)

  if (filter_obj$type != "OR") {
    stop("Filter type must be 'OR'")
  }

  # Move row names to a column if present
  has_row_names <- tibble::has_rownames(table)
  if (has_row_names) {
    table <- tibble::rownames_to_column(table, "SPARRA_PRIVATE_ROW_NAMES")
  }

  # Attach an index column to label the rows. This step gets rid of preexisting
  # row names hence the check above
  table <- tibble::rowid_to_column(table, "SPARRA_PRIVATE_INDEX")

  # Pass the input table through each subfilter in turn. To avoid doing more
  # work than necessary, once a row passes any of the subfilters, it is added
  # to the 'passed' table and we don't need to check it against the remaining
  # subfilters.
  n <- length(filter_obj$subfilters)
  passed <- tibble()
  not_yet_passed <- table
  for (i in seq_along(filter_obj$subfilters)) {
    subfilter <- filter_obj$subfilters[[i]]
    extra_ctx <- paste0("(", i, "/", n, ")")
    subfilter_result <- filter_all(
      not_yet_passed,
      subfilter,
      c(context, extra_ctx)
    )
    passed <- bind_rows(passed, subfilter_result$passed)
    not_yet_passed <- subfilter_result$rejected
  }

  # Sort by the index column (to restore the input order) and remove it
  passed <- passed %>%
    arrange(SPARRA_PRIVATE_INDEX) %>%
    select(-SPARRA_PRIVATE_INDEX)

  rejected <- not_yet_passed %>%
    arrange(SPARRA_PRIVATE_INDEX) %>%
    select(-SPARRA_PRIVATE_INDEX)

  # Restore row names if present
  if (has_row_names) {
    passed <- tibble::column_to_rownames(passed, "SPARRA_PRIVATE_ROW_NAMES")
    rejected <- tibble::column_to_rownames(rejected, "SPARRA_PRIVATE_ROW_NAMES")
  }

  list(passed = passed, rejected = rejected)
}
