#' Perform (date) preprocessing on a given data table
#'
#' @param input_table The original input table which will be mutated
#' @param spec The specification which dictates the changes
#' @param context Execution context
#'
#' @return A mutated version of the initial input table
#' @export
preprocess_table <- function(
    input_table,
    spec,
    context = NULL) {
  context <- c(context, "preprocess_table")
  debug_context("Mutating original data table")

  # identify useful variables
  grouping_column <- validate_column_present(
    "grouping_column", spec, input_table, context
  )
  preprocess_on <- validate_column_present(
    "on", spec$preprocess, input_table, context
  )
  # TODO: Allow retain_{min,max} to have multiple values
  retain_min <- validate_column_present(
    "retain_min", spec$preprocess, input_table, context
  )
  retain_max <- validate_column_present(
    "retain_max", spec$preprocess, input_table, context
  )

  # Find the earliest (admission) and latest (discharge) date for each group
  min_values <- input_table %>%
    group_by(
      across(all_of(grouping_column)),
      across(all_of(preprocess_on))
    ) %>%
    summarise(EIDER_MIN_PREPROC = min(!!sym(retain_min)))

  max_values <- input_table %>%
    group_by(
      across(all_of(grouping_column)),
      across(all_of(preprocess_on))
    ) %>%
    summarise(EIDER_MAX_PREPROC = max(!!sym(retain_max)))

  # Replace the minimum (admission likely) in the original dataframe
  # with the earliest date
  input_table <- input_table %>%
    left_join(min_values, by = c(grouping_column, preprocess_on)) %>%
    mutate(!!retain_min := EIDER_MIN_PREPROC) %>%
    select(-EIDER_MIN_PREPROC)

  # Replace the maximum (discharge likely) in the original dataframe
  # with the latest date
  input_table <- input_table %>%
    left_join(max_values, by = c(grouping_column, preprocess_on)) %>%
    mutate(!!retain_max := EIDER_MAX_PREPROC) %>%
    select(-EIDER_MAX_PREPROC)

  return(input_table)
}
