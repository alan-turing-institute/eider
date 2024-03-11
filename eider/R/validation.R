#' Checks that `spec$source_file` is a single string and that it is a key in
#' `all_tables`. If so, returns the table itself (or the file path of the
#' table).
validate_source_file <- function(spec, all_tables, context) {
  n <- spec$source_file

  if (!(is.character(n) && length(n) == 1)) {
    error_context("'source_file' must be a single string.", context)
  }

  if (!(n %in% names(all_tables))) {
    error_context(
      paste0(
        "The name '",
        n,
        "' supplied for 'source_file' was not provided as an input table."
      ), context
    )
  }

  all_tables[[n]]
}

#' Checks that `spec$output_feature_name` is a single string. If so, returns
#' the string.
validate_output_feature_name <- function(spec, context) {
  n <- spec$output_feature_name

  if (!(is.character(n) && length(n) == 1)) {
    error_context("'output_feature_name' must be a single string.", context)
  }

  n
}

#' Checks that `spec[[field_name]]` is a single string and that it is a column
#' in the table `tbl`. If so, returns the column name.
validate_column_present <- function(field_name, spec, tbl, context) {
  n <- spec[[field_name]]

  if (!(is.character(n) && length(n) == 1)) {
    error_context(
      paste0("'", field_name, "' must be a single string."),
      context
    )
  }

  if (!(n %in% names(tbl))) {
    error_context(
      paste0(
        "The column '",
        n,
        "' supplied for '",
        field_name,
        "' was not found in the input table."
      ), context
    )
  }

  n
}


#' Checks that `spec$absent_default_value` is a single number. If so, returns
#' the number.
validate_absent_default_value <- function(spec, context) {
  n <- spec$absent_default_value

  if (is.null(n)) {
    return(NA)
  }

  if (!(is.numeric(n) && length(n) == 1)) {
    error_context(
      "If provided, 'absent_default_value' must be a single number.",
      context
    )
  }

  n
}
