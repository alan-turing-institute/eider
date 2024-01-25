make_raw_smr00 <- function(){
  library(dplyr)
  n <- 6
  nid <- 15
  seed <- 468
  set.seed(seed)

  id <- sample(nid, n)
  ## Synthesise demographic data for each of the `nid` patients
  id_dob <- as.Date.numeric(sample(80 * 365, nid, rep = TRUE), origin = "1930-01-01")
  id_s <- sample(c(1, 2, 0, 9), nid, rep = TRUE, prob = c(20, 20, 1, 1))
  id_simd <- factor(sample(c("1=most deprived", 2:9, "10=least deprived"), nid, rep = TRUE),
                    levels = c("1=most deprived", 2:9, "10=least deprived")
  )

  ATTENDANCE_FOLLOW_UP <- sample(c("", 1:5, 8), n, replace = TRUE)
  CLINIC_ATTENDANCE <- sample(c(1, 5, 8), n, replace = TRUE)
  CLINIC_DATE <- as.Date.numeric(sample(7 * 365, n, rep = TRUE), origin = "2011-01-01")
  DOB <- id_dob[id]
  DATE_OF_MAIN_OPERATION <- as.Date(rep(NA, n))
  s0 <- sample(n, round(0.3 * n))
  DATE_OF_MAIN_OPERATION[s0] <- as.Date.numeric(sample(7 * 365, length(s0), rep = TRUE), origin = "2011-01-01")
  DATE_OF_OTHER_OPERATION_1 <- as.Date(rep(NA, n))
  s1 <- sample(s0, round(length(s0) * 0.3))
  DATE_OF_OTHER_OPERATION_1[s1] <- as.Date.numeric(sample(7 * 365, length(s1)), origin = "2011-01-01")
  DATE_OF_OTHER_OPERATION_2 <- as.Date(rep(NA, n))
  s2 <- sample(s1, round(length(s1) * 0.3), rep = TRUE)
  DATE_OF_OTHER_OPERATION_2[s2] <- as.Date.numeric(sample(7 * 365, length(s2), rep = TRUE), origin = "2011-01-01")
  DATE_OF_OTHER_OPERATION_3 <- as.Date(rep(NA, n))
  s3 <- sample(s2, round(length(s2) * 0.3))
  DATE_OF_OTHER_OPERATION_3[s3] <- as.Date.numeric(sample(7 * 365, length(s3), rep = TRUE), origin = "2011-01-01")
  GP_PRACTICE_CODE <- sample(10000, n, rep = TRUE)
  HBRES_CURRENT_DATE <- paste0("S080000", sample(100, n, rep = TRUE))
  HBTREAT_CURRENT_DATE <- paste0("S080000", sample(100, n, rep = TRUE))
  LOCATION <- toupper(paste0(sample(letters, n, rep = TRUE), sample(100, n, rep = TRUE), sample(letters, n, rep = TRUE)))
  MAIN_CONDITION <- sample(c("", "A"), n, rep = TRUE, prob = c(1, 20))
  s <- which(MAIN_CONDITION == "A")
  MAIN_CONDITION[s] <- toupper(paste0(sample(letters, length(s), rep = TRUE), sample(999, length(s), rep = TRUE)))
  OTHER_CONDITION_1 <- rep("", n)
  s1 <- sample(s, round(length(s) * 0.5))
  OTHER_CONDITION_1[s1] <- toupper(paste0(sample(letters, length(s1), rep = TRUE), sample(999, length(s1), rep = TRUE)))
  OTHER_CONDITION_2 <- rep("", n)
  s2 <- sample(s1, round(length(s1) * 0.5))
  OTHER_CONDITION_1[s2] <- toupper(paste0(sample(letters, length(s2), rep = TRUE), sample(999, length(s2), rep = TRUE)))
  OTHER_CONDITION_3 <- rep("", n)
  s3 <- sample(s2, round(length(s2) * 0.5))
  OTHER_CONDITION_1[s3] <- toupper(paste0(sample(letters, length(s3), rep = TRUE), sample(999, length(s3), rep = TRUE)))
  OTHER_CONDITION_4 <- rep("", n)
  s4 <- sample(s3, round(length(s3) * 0.5))
  OTHER_CONDITION_1[s4] <- toupper(paste0(sample(letters, length(s4), rep = TRUE), sample(999, length(s4), rep = TRUE)))
  OTHER_CONDITION_5 <- rep("", n)
  s5 <- sample(s4, round(length(s4) * 0.5))
  OTHER_CONDITION_1[s5] <- toupper(paste0(sample(letters, length(s5), rep = TRUE), sample(999, length(s5), rep = TRUE)))
  MAIN_OPERATION <- sample(c("", "A"), n, rep = TRUE, prob = c(1, 20))
  s <- which(MAIN_OPERATION == "A")
  MAIN_OPERATION[s] <- toupper(paste0(sample(letters, length(s), rep = TRUE), sample(999, length(s), rep = TRUE)))
  MODE_OF_CONTACT <- sample(c("", 1:3), n, rep = TRUE)
  OTHER_OPERATION_1 <- rep("", n)
  s1 <- sample(s, round(length(s) * 0.5))
  OTHER_OPERATION_1[s1] <- toupper(paste0(sample(letters, length(s1), rep = TRUE), sample(999, length(s1), rep = TRUE)))
  OTHER_OPERATION_2 <- rep("", n)
  s2 <- sample(s1, round(length(s1) * 0.5))
  OTHER_OPERATION_1[s2] <- toupper(paste0(sample(letters, length(s2), rep = TRUE), sample(999, length(s2), rep = TRUE)))
  OTHER_OPERATION_3 <- rep("", n)
  s3 <- sample(s2, round(length(s2) * 0.5))
  OTHER_OPERATION_1[s3] <- toupper(paste0(sample(letters, length(s3), rep = TRUE), sample(999, length(s3), rep = TRUE)))
  PATIENT_CATEGORY <- sample(c(2, 3, 4, 5), n, rep = TRUE)
  REFERRAL_TYPE <- sample(c(1:3), n, rep = TRUE)
  SEX <- id_s[id]
  SIGNIFICANT_FACILITY <- sample(c("", 11, 31:39), n, rep = TRUE)
  SPECIALTY <- toupper(paste0(sample(letters, n, rep = TRUE), sample(99, n, rep = TRUE)))
  TWELVE_MONTH_TIME_PERIOD <- paste0("y", sample(4, n, rep = TRUE))
  simd2016_sc_decile <- id_simd[id]
  simd2016_sc_quintile <- ceiling(as.numeric(id_simd[id]) / 2)
  simd2016_HB2014_decile <- simd2016_sc_decile
  simd2016_HB2014_quintile <- simd2016_sc_quintile
  simd2016tp15 <- as.numeric(simd2016_sc_decile) > 8
  simd2016bt15 <- as.numeric(simd2016_sc_decile) < 2
  UNIQUE_STUDY_ID <- id

  smr00_df <- data.frame(ATTENDANCE_FOLLOW_UP, CLINIC_ATTENDANCE, CLINIC_DATE, DOB, DATE_OF_MAIN_OPERATION, DATE_OF_OTHER_OPERATION_1,
                         DATE_OF_OTHER_OPERATION_2, DATE_OF_OTHER_OPERATION_3, GP_PRACTICE_CODE, HBRES_CURRENT_DATE, HBTREAT_CURRENT_DATE, LOCATION, MAIN_CONDITION,
                         OTHER_CONDITION_1, OTHER_CONDITION_2, OTHER_CONDITION_3, OTHER_CONDITION_4, OTHER_CONDITION_5, MAIN_OPERATION, MODE_OF_CONTACT, OTHER_OPERATION_1,
                         OTHER_OPERATION_2, OTHER_OPERATION_3, PATIENT_CATEGORY, REFERRAL_TYPE, SEX, SIGNIFICANT_FACILITY, SPECIALTY, TWELVE_MONTH_TIME_PERIOD,
                         simd2016_sc_decile, simd2016_sc_quintile, simd2016_HB2014_decile, simd2016_HB2014_quintile, simd2016tp15, simd2016bt15, UNIQUE_STUDY_ID, stringsAsFactors = FALSE) %>%
    adjust_date_format()

  return(smr00_df)
}
