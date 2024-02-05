#' Computes the number of rows per patient ID which contain a specific
#' diagnosis code.
#'
#' @param ae2 Cleaned AE2 data.frame.
#' @param target_diagnoses Vector of diagnosis codes to count.
#'
#' TODO: Generalise over the following:
#' - 'diagnosis_x' column names
#' - 'id' column name
#' - source table name
featurise_count_per_id <- function(ae2,
                                   target_diagnoses,
                                   output_column_name) {
  ae2 %>%
    filter(diagnosis_1 %in% target_diagnoses |
      diagnosis_2 %in% target_diagnoses |
      diagnosis_3 %in% target_diagnoses) %>%
    group_by(id) %>%
    summarise("{output_column_name}" := n())
}
