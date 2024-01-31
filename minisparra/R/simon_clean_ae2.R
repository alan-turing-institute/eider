clean_ae2 <- function(ae2) {
  #' clean_ae2
  #' @description Cleans the AE2 table. Note it adds referral_type if it
  #' doesn't exist
  #' @param ae2 data.frame of ae2 records to be cleaned
  #' @returns ae2 data.frame of cleaned ae2 data
  #log_info("Cleaning AE2")
  `%notin%` = Negate(`%in%`)
  if ("attendance_category" %notin% names(ae2)) {
    print("Attendance category not in AE2, adding with default value of 1")
    ae2 <- ae2 %>% mutate(attendance_category = 1)
  }

  table_names <- c("AE2","Patient_lookup")
  source_names = c("PIS","SMR01M",grep("PIS",table_names,val=T,invert=T))


  ae2 <- ae2 %>%
    transmute(
      id = as.character(UNIQUE_STUDY_ID),
      time = lubridate::dmy(ADMISSION_DATE),
      attendance_category = as.numeric(attendance_category),
      source_table = factor("AE2", levels = source_names),
      diagnosis_1 = as.numeric(DIAGNOSIS_1),
      diagnosis_2 = as.numeric(DIAGNOSIS_2),
      diagnosis_3 = as.numeric(DIAGNOSIS_3)
    )
  return(ae2)
}
