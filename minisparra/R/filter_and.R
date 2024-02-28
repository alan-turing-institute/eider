#' Filter table rows based on a logical conjunction of multiple filters (i.e.
#' filter1 AND filter2 AND ...)
#'
#' @param table A data frame
#' @param filter_obj A list containing the following elements:
#'               - type: must be 'and' (case-insensitive)
#'               - subfilters: a list of filter objects
#' @param context A string to be used in logging or error messages. Defaults to
#' NULL.
#'
#' @return A list with the following elements:
#'               - passed: data frame with the rows that passed the filter
#'               - rejected: all other rows
filter_and <- function(table,
                       filter_obj,
                       context = NULL) {
  context <- c(context, "filter_and")
  trace_context(context)

  if (tolower(filter_obj$type) != "and") {
    error_context(
      paste0("Expected filter type 'and', but got '", filter_obj$type, "'."),
      context
    )
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
  # work than necessary, once a row fails any of the subfilters, it is added to
  # the 'failed' table and we don't need to check it against the remaining
  # subfilters.
  n <- length(filter_obj$subfilters)
  not_yet_failed <- table
  failed <- tibble()
  for (i in seq_along(filter_obj$subfilters)) {
    nm <- names(filter_obj$subfilters)[[i]]
    extra_ctx <- paste0("(", i, "/", n, ": ", nm, ")")
    subfilter_result <- filter_all(
      not_yet_failed,
      filter_obj$subfilters[[i]],
      c(context, extra_ctx)
    )
    not_yet_failed <- subfilter_result$passed
    failed <- bind_rows(failed, subfilter_result$rejected)
  }

  # Sort by the index column (to restore the input order) and remove it
  passed <- not_yet_failed %>%
    arrange(SPARRA_PRIVATE_INDEX) %>%
    select(-SPARRA_PRIVATE_INDEX)

  rejected <- failed %>%
    arrange(SPARRA_PRIVATE_INDEX) %>%
    select(-SPARRA_PRIVATE_INDEX)

  # Restore row names if present
  if (has_row_names) {
    passed <- tibble::column_to_rownames(passed, "SPARRA_PRIVATE_ROW_NAMES")
    rejected <- tibble::column_to_rownames(rejected, "SPARRA_PRIVATE_ROW_NAMES")
  }

  list(passed = passed, rejected = rejected)
}
