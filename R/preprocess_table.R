#' Perform (date) preprocessing on a given data table
#'
#' @param input_table The original input table which will be mutated
#' @param spec The specification which dictates the changes
#' @param context Execution context, defaulting to NULL
#'
#' @return A mutated version of the initial input table
#' @noRd
preprocess_table <- function(input_table, spec, context = NULL) {
  context <- c(context, "preprocess_table")

  if ("preprocess" %in% names(spec)) {
    debug_context(
      context,
      message = paste0("Preprocessing table ", spec$source_file)
    )

    on <- validate_columns_present(
      "on", spec$preprocess, input_table, context
    )
    retain_min <- validate_columns_present(
      "retain_min", spec$preprocess, input_table, context
    )
    retain_max <- validate_columns_present(
      "retain_max", spec$preprocess, input_table, context
    )

    input_table <- input_table %>% group_by(across(all_of(on)))

    for (col in retain_min) {
      input_table <- input_table %>%
        mutate(!!col := min(!!sym(col)))
    }

    for (col in retain_max) {
      input_table <- input_table %>%
        mutate(!!col := max(!!sym(col)))
    }

    input_table %>% ungroup()
  } else {
    debug_context(
      context,
      message = "No preprocessing specified for this feature"
    )
    input_table
  }
}
