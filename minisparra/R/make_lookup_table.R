#' @export
make_lookup <- function(){
  library(dplyr)
  n <- 6
  nid <- 15
  seed <- 468
  set.seed(seed)

  ## Synthesise demographic data for each of the `nid` patients
  id_dob <- as.Date.numeric(sample(80 * 365, nid, rep = TRUE), origin = "1930-01-01")
  id_s <- sample(c(1, 2, 0, 9), nid, rep = TRUE, prob = c(20, 20, 1, 1))
  id_simd <- factor(sample(c("1=most deprived", 2:9, "10=least deprived"), nid, rep = TRUE),
                    levels = c("1=most deprived", 2:9, "10=least deprived")
  )

  UNIQUE_STUDY_ID <- 1:nid
  GENDER <- id_s
  DOB <- id_dob
  SIMD_QUINTILE_2016_SCT <- ceiling(as.numeric(id_simd) / 2)
  SIMD_DECILE_2016_SCT <- as.numeric(id_simd)

  lookup_df <- data.frame(
    UNIQUE_STUDY_ID,GENDER,DOB,SIMD_QUINTILE_2016_SCT,SIMD_DECILE_2016_SCT,
    stringsAsFactors=FALSE) %>%
    adjust_date_format()
  return(lookup_df)
}
