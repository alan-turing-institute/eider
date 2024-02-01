#' Computes features from the AE2 table, including the count of AE2 records per
#' id, number of drug and alcohol attendances, and number of psych attendances.

#' @param ae2 Cleaned AE2 data.frame. Must include the following columns:
#'  id, attendance_category, diagnosis_1, diagnosis_2, diagnosis_3
#' @returns data.frame with th efollowing columns:
#'  id, num_ae2_attendances, num_alcohol_drug_attendances, num_psych_attendances
#' @export
count_ae2_attendance_features <- function(ae2) {
  ae2 <- ae2 %>%
    filter(attendance_category == 1 | attendance_category == 3)

  # Calculate the number of AE2 attendances per id
  feature_df <- ae2 %>%
    group_by(id) %>%
    summarise(num_ae2_attendances = n())

  # Number of alcohol and drug attendances
  alcohol_drug_diagnoses <- 73
  feature_df <- join_feature_df(
    feature_df,
    count_matching_diagnoses(ae2, alcohol_drug_diagnoses, "num_alcohol_drug_attendances")
  )

  # Number of psychiatric attendances
  psych_diagnoses <- 16
  feature_df <- join_feature_df(
    feature_df,
    count_matching_diagnoses(ae2, psych_diagnoses, "num_psych_attendances")
  )

  # Replace NA values with 0
  feature_df[is.na(feature_df)] <- 0
  feature_df
}

#' Computes the number of AE2 attendances with a given diagnosis.
#' @param ae2 Cleaned AE2 data.frame.
#' @param target_diagnoses Vector of diagnosis codes to count.
count_matching_diagnoses <- function(ae2, target_diagnoses, output_column_name) {
  ae2 %>%
    filter(diagnosis_1 %in% target_diagnoses |
      diagnosis_2 %in% target_diagnoses |
      diagnosis_3 %in% target_diagnoses) %>%
    group_by(id) %>%
    summarise("{output_column_name}" := n())
}
