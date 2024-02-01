ae2_attendances <- function(AE2, target_diagnosis) {
  #' ae2_attendances
  #' @description Computes the features including the count of AE2 records per
  #' id, number of drug and alcohol attendances and number of pysch attendances
  #' @param AE2 data.frame including AE2 records
  #' @param target_diagnosis integer specifying the target diagnosis number
  #' @returns feature_df data.frame with id and num_ae2_attendances columns
  #'

  # Make dictionary of key value pairs for diagnosis name and diagnosis integer
  diagnosis_dict <- c(19, 73, 76)
  diagnosis_names <- c("nineteen", "seventy-three", "seventy-six")
  names(diagnosis_dict) <- diagnosis_names
  diagnosis_type <- get_key(diagnosis_dict, target_diagnosis)
  column_header <- paste("num", diagnosis_type, "attendances", sep = "_")

  AE2 <- AE2 %>%
    filter(attendance_category == 1 | attendance_category == 3)
  # num_ae2_attendances
  feature_df <- AE2 %>%
    group_by(id) %>%
    summarise(num_ae2_attendances = n())

  # num_$target_diagnosis_attendances
  feature_df <- join_feature_df(
    feature_df,
    AE2 %>%
      filter(diagnosis_1 %in% target_diagnosis | diagnosis_2 %in% target_diagnosis |
               diagnosis_3 %in% target_diagnosis) %>%
      group_by(id) %>%
      summarise(new_feature_column_name = n())
  )
  names(feature_df)[names(feature_df) == 'new_feature_column_name'] <-
    column_header

  feature_df[is.na(feature_df)] <- 0
  return(feature_df)
}
