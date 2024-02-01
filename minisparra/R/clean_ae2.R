#' Cleans the AE2 table. Adds the attendance_category column and populates it
#' with 1 if it doesn't exist.
#'
#' @param ae2 data.frame of ae2 records to be cleaned. The following columns must exist:
#' admission_date, diagnosis_1, diagnosis_2, diagnosis_3, as well as the column
#' referred to in patient_id_col
#' @param patient_id_col name of column in ae2 containing patient IDs. Defaults
#' to "unique_study_id"
#' @returns data.frame of cleaned ae2 data
#' @export
clean_ae2 <- function(ae2,
                      patient_id_col = "unique_study_id") {
  if (!("attendance_category" %in% names(ae2))) {
    print("attendance_category column not in AE2; adding with default value of 1")
    ae2 <- ae2 %>% mutate(attendance_category = 1)
  }

  # Check that all required columns are present
  required_columns <- c("admission_date", "diagnosis_1", "diagnosis_2", "diagnosis_3", patient_id_col)
  columns_not_present <- required_columns[!(required_columns %in% names(ae2))]
  if (length(columns_not_present) > 0) {
    stop(
      "Not all required columns were present in input AE2 data. The following columns were missing: ",
      paste(columns_not_present, collapse = ", ")
    )
  }

  table_names <- c("AE2", "Patient_lookup")
  table_names_without_pis <- grep("PIS", table_names, val = TRUE, invert = TRUE)
  source_names <- c("PIS", "SMR01M", table_names_without_pis)

  ae2 %>%
    transmute(
      id = as.character(.data[[patient_id_col]]),
      time = lubridate::dmy(admission_date),
      attendance_category = as.numeric(attendance_category),
      source_table = factor("AE2", levels = source_names),
      diagnosis_1 = as.numeric(diagnosis_1),
      diagnosis_2 = as.numeric(diagnosis_2),
      diagnosis_3 = as.numeric(diagnosis_3)
    )
}



#' James's version of AE2 cleaning, tidied up to avoid using files.
#' Mostly kept here for posterity.
#'
#' @param table_AE2 data.frame of AE2 records to be cleaned. The following
#' column names must be present: unique_study_id, admission_date,
#' admission_time, transfer_discharge_date, transfer_discharge_time.
#' @param patient_id_col name of column in ae2 containing patient IDs. Defaults
#' to "unique_study_id"
#' @returns data.frame of cleaned AE2 data
#'
#' @export
clean_ae2_jl <- function(table_ae2,
                         patient_id_col = "unique_study_id") {
  table_names <- c("AE2", "Patient_lookup")
  source_names <- c("PIS", "SMR01M", grep("PIS", table_names, val = TRUE, invert = TRUE))

  # Helper function to turn "numerise-able" columns into real numeric columns
  numerise_columns <- function(df) {
    df %>% dplyr::mutate_if(
      ~ (is.character(.) | is.factor(.)),
      function(x) {
        if (all(varhandle::check.numeric(x))) {
          as.numeric(x)
        } else {
          x
        }
      }
    )
  }

  table_ae2 %>%
    dplyr::mutate(
      id = as.integer(.data[[patient_id_col]]),
      source_table = factor("AE2", levels = source_names),
      source_row = as.integer(row_number()),
      time = lubridate::parse_date_time(
        stringr::str_c(admission_date, admission_time, sep = " "),
        orders = c("d m Y H M")
      ),
      time_discharge = lubridate::parse_date_time(
        stringr::str_c(transfer_discharge_date, transfer_discharge_time, sep = " "),
        orders = c("d m Y H M")
      )
    ) %>%
    dplyr::select(-c(unique_study_id, admission_date, admission_time, transfer_discharge_date, transfer_discharge_time)) %>%
    dplyr::mutate_if(is.character, ~ ifelse(nchar(.) == 0, NA, .)) %>%
    numerise_columns() %>%
    filter(!is.na(id)) # No point keeping records with no ID. Typically very few.
}
