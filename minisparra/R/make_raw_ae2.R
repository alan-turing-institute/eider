#' Generate a raw AE2 table.
#'
#' @param n Number of rows to generate.
#' @param nid Number of unique study IDs to generate.
#' @param seed Seed for random number generation.
#' @export
make_raw_ae2 <- function(n = 6, nid = 15, seed = 468) {
  set.seed(seed)

  twelve_month_time_period <- paste0("y", sample(4, n, rep = TRUE))
  admission_date <- as.Date.numeric(sample(7 * 365, n, rep = TRUE), origin = "2013-01-01")
  admission_time <- paste0(sample(0:23, n, rep = TRUE), ":", sample(0:59, n, rep = TRUE))
  transfer_discharge_date <- as.Date(admission_date + sample(10, n, rep = TRUE))
  transfer_discharge_time <- paste0(sample(0:23, n, rep = TRUE), ":", sample(0:59, n, rep = TRUE))
  diagnosis_1 <- sample(99, n, rep = TRUE)
  diagnosis_2 <- sample(99, n, rep = TRUE)
  diagnosis_3 <- rep("", n)
  discharge_destination <- paste0("0", sample(9, n, rep = TRUE), toupper(sample(letters, n, rep = TRUE)))
  location_code <- paste0(toupper(sample(letters, n, rep = TRUE)), sample(100:999, n, rep = TRUE), toupper(sample(letters, n, rep = TRUE)))
  referral_source <- paste0("0", sample(9, n, rep = TRUE), toupper(sample(letters, n, rep = TRUE)))
  unique_study_id <- sample(nid, n, rep = FALSE)

  data.frame(twelve_month_time_period, admission_date, admission_time,
    transfer_discharge_date, transfer_discharge_time,
    diagnosis_1, diagnosis_2, diagnosis_3,
    discharge_destination, location_code, referral_source,
    unique_study_id,
    stringsasfactors = FALSE
  ) %>%
    adjust_date_format()
}
