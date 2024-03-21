#' Perform (date) preprocessing on a given data table
#'
#' @param input_table The original input table which will be mutated
#' @param spec The specification which dictates the changes
#'
#' @return A mutated version of the initial input table
#' @export
preprocess_table <- function(input_table,
                             spec) {
  log_debug("Mutating original data table")

  # identify useful variables
  grouping_column <- spec$grouping_column
  preprocess_on <- spec$preprocess$on
  retain_min <- spec$preprocess$retain_min
  retain_max <- spec$preprocess$retain_max

  # Ensure date formats are consistent
  input_table[[retain_min]] <- as.Date(input_table[[retain_min]])
  input_table[[retain_max]] <- as.Date(input_table[[retain_max]])

  # Find the earliest (admission) and latest (discharge) date for each group
  min_dates <- input_table %>% group_by(across(all_of(grouping_column)),
                                        across(all_of(preprocess_on))) %>%
    summarise(min_date = min(!!sym(retain_min)))
  max_dates <- input_table %>% group_by(across(all_of(grouping_column)),
                                        across(all_of(preprocess_on))) %>%
    summarise(max_date = max(!!sym(retain_max)))

  # Replace the minimum (admission likely) in the original dataframe
  # with the earliest date
  input_table <- input_table %>%
    left_join(min_dates, by = c(grouping_column, preprocess_on)) %>%
    mutate(!!retain_min := min_date) %>%
    select(-min_date)

  # Replace the maximum (discharge likely) in the original dataframe
  # with the latest date
  input_table <- input_table %>%
    left_join(max_dates, by = c(grouping_column, preprocess_on)) %>%
    mutate(!!retain_max := max_date) %>%
    select(-max_date)

  return(input_table)
}
