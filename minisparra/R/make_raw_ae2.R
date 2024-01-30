#' @export
make_raw_ae2 <- function(){
  n <- 6
  nid <- 15
  seed <- 468
  set.seed(seed)

  ## AE2 table table. This ordinarily gets saved as
  ## Final_AE2_extract_incl_UniqueStudyID.zsav
  TWELVE_MONTH_TIME_PERIOD <- paste0("y", sample(4, n, rep = TRUE))
  ADMISSION_DATE <- as.Date.numeric(sample(7 * 365, n, rep = TRUE), origin = "2013-01-01")
  ADMISSION_TIME <- paste0(sample(0:23, n, rep = TRUE), ":", sample(0:59, n, rep = TRUE))
  TRANSFER_DISCHARGE_DATE <- as.Date(ADMISSION_DATE + sample(10, n, rep = TRUE))
  TRANSFER_DISCHARGE_TIME <- paste0(sample(0:23, n, rep = TRUE), ":", sample(0:59, n, rep = TRUE))
  DIAGNOSIS_1 <- sample(99, n, rep = TRUE)
  DIAGNOSIS_2 <- sample(99, n, rep = TRUE)
  DIAGNOSIS_3 <- rep("", n)
  DISCHARGE_DESTINATION <- paste0("0", sample(9, n, rep = TRUE), toupper(sample(letters, n, rep = TRUE)))
  LOCATION_CODE <- paste0(toupper(sample(letters, n, rep = TRUE)), sample(100:999, n, rep = TRUE), toupper(sample(letters, n, rep = TRUE)))
  REFERRAL_SOURCE <- paste0("0", sample(9, n, rep = TRUE), toupper(sample(letters, n, rep = TRUE)))
  UNIQUE_STUDY_ID <- sample(nid, n, rep = FALSE)

  ae2_df <- data.frame(TWELVE_MONTH_TIME_PERIOD, ADMISSION_DATE, ADMISSION_TIME,
                       TRANSFER_DISCHARGE_DATE, TRANSFER_DISCHARGE_TIME,
                       DIAGNOSIS_1, DIAGNOSIS_2, DIAGNOSIS_3,
                       DISCHARGE_DESTINATION, LOCATION_CODE, REFERRAL_SOURCE,
                       UNIQUE_STUDY_ID, stringsAsFactors = FALSE) %>%
  adjust_date_format()

  return(ae2_df)
}
