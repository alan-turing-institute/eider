ae2_attendances <- function(AE2) {
  #' ae2_attendances
  #' @description Computes the features including the count of AE2 records per id,
  #' number of drug and alcohol attendances and number of pysch attendances
  #' @param AE2 data.frame including AE2 records
  #' @returns feature_df data.frame with id and num_ae2_attendances columns
  AE2 <- AE2 %>%
    filter(attendance_category == 1 | attendance_category == 3)
  # num_ae2_attendances
  feature_df <- AE2 %>%
    group_by(id) %>%
    summarise(num_ae2_attendances = n())

  target_diagnosis = 73
  # num_alcohol_drug_attendances
  feature_df <- join_feature_df(
    feature_df,
    AE2 %>%
      filter(diagnosis_1 %in% target_diagnosis | diagnosis_2 %in% target_diagnosis |
               diagnosis_3 %in% target_diagnosis) %>%
      group_by(id) %>%
      summarise(descriptive_column_name = n())
  )
  # num_psych_attednances
  #feature_df <- join_feature_df(
 #   feature_df,
#    AE2 %>%
      #filter(diagnosis_1 == 16 | diagnosis_2 == 16 | diagnosis_3 == 16) %>%
      #group_by(id) %>%
      #summarise(num_psych_attendances = n())
  #)
  feature_df[is.na(feature_df)] <- 0
  return(feature_df)
}
