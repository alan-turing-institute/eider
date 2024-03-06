#' Filter table rows based on a logical disjunction of multiple filters (i.e.
#' filter1 OR filter2 OR ...)
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'or' (case-insensitive)
#'               - subfilters: a list of filter objects
#' @param context A string to be used in logging or error messages. Defaults to
#' NULL.
#'
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
filter_or <- function(table, filter_obj, context = NULL) {
  context <- c(context, "filter_or")
  trace_context(context)

  if (tolower(filter_obj$type) != "or") {
    error_context(
      paste0("Expected filter type 'or', but got '", filter_obj$type, "'."),
      context
    )
  }

  # Move row names to a column if present
  has_row_names <- tibble::has_rownames(table)
  if (has_row_names) {
    table <- tibble::rownames_to_column(table, "EIDER_PRIVATE_ROW_NAMES")
  }

  # Attach an index column to label the rows. This step gets rid of preexisting
  # row names hence the check above
  has_indices <- "EIDER_PRIVATE_INDEX" %in% names(table)
  if (!has_indices) {
    table <- tibble::rowid_to_column(table, "EIDER_PRIVATE_INDEX")
  }

  # Pass the input table through each subfilter in turn. To avoid doing more
  # work than necessary, once a row passes any of the subfilters, it is added
  # to the 'passed' table and we don't need to check it against the remaining
  # subfilters.
  n <- length(filter_obj$subfilters)
  passed <- tibble()
  not_yet_passed <- table
  for (i in seq_along(filter_obj$subfilters)) {
    nm <- names(filter_obj$subfilters)[[i]]
    extra_ctx <- paste0("(", i, "/", n, ": ", nm, ")")
    subfilter_result <- filter_all(
      not_yet_passed,
      filter_obj$subfilters[[i]],
      c(context, extra_ctx)
    )
    passed <- bind_rows(passed, subfilter_result$passed)
    not_yet_passed <- subfilter_result$rejected
  }

  # Sort by the index column (to restore the input order) and remove it
  if (!has_indices) {
    passed <- passed %>%
      arrange(EIDER_PRIVATE_INDEX) %>%
      select(-EIDER_PRIVATE_INDEX)
    not_yet_passed <- not_yet_passed %>%
      arrange(EIDER_PRIVATE_INDEX) %>%
      select(-EIDER_PRIVATE_INDEX)
  }

  # Restore row names if present
  if (has_row_names) {
    passed <- tibble::column_to_rownames(
      passed,
      "EIDER_PRIVATE_ROW_NAMES"
    )
    not_yet_passed <- tibble::column_to_rownames(
      not_yet_passed,
      "EIDER_PRIVATE_ROW_NAMES"
    )
  }

  list(passed = passed, rejected = not_yet_passed)
}
