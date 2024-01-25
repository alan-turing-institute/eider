##' Clean raw data and generate tidy versions of data tables. Will only update episodes table if force_redo = TRUE.
##'
##' @param force_redo Redo if clean data are not already there
##' @param dir_rawData directory containing raw data tables (from EHRs)
##' @param dir_cleanData directory to which clean data tables will be written
##' @returns NULL
##' @export
clean_rawData_ae2 <- function(force_redo = TRUE,
                          dir_rawData = ".",
                          dir_cleanData = "."){

  # Raw data files
  data_filenames <- c("Final_AE2_extract_incl_UniqueStudyID.zsav",
                      "LOOKUP_SIMD_sex_dob_for_ATI.zsav")

  table_names <- c("AE2","Patient_lookup")

  names(data_filenames) <- table_names

  source_names = c("PIS","SMR01M",grep("PIS",table_names,val=T,invert=T))

  # Helper function to turn "numerise-able" columns into real numeric columns
  numerise_columns <- function(.data) {
    .data %>%
      mutate_if(
        ~(is.character(.) | is.factor(.)),
        function(x){
          if (all(varhandle::check.numeric(x))){
            as.numeric(x)
          } else
            x
        }
      )
  }

  cleanData_filenames <- c("AE2.fst",
                           "patients.fst")

  #---------------------------------
  #              AE2
  #---------------------------------
  ae2_filepath_clean <- file.path(dir_cleanData,"AE2.fst")
  cat(paste0("... cleaning file: ", ae2_filepath_clean, "\n"))
  table_AE2 <- haven::read_sav(file.path(dir_rawData, data_filenames[["AE2"]]))
  library(tidyverse)
  glimpse(table_AE2)

  # Parse the times
  table_AE2 <- table_AE2 %>%
    mutate(
      id = as.integer(UNIQUE_STUDY_ID),
      source_table = factor("AE2", levels = source_names),
      source_row = as.integer(row_number()),
      time = lubridate::parse_date_time(
        stringr::str_c(ADMISSION_DATE, ADMISSION_TIME, sep=" "),
        orders = c("d m Y H M")
      ),
      time_discharge = lubridate::parse_date_time(
        stringr::str_c(TRANSFER_DISCHARGE_DATE, TRANSFER_DISCHARGE_TIME, sep=" "),
        orders = c("d m Y H M")
      )
    ) %>%
    select(-c(UNIQUE_STUDY_ID, ADMISSION_DATE, ADMISSION_TIME, TRANSFER_DISCHARGE_DATE, TRANSFER_DISCHARGE_TIME)) %>%
    mutate_if(is.character, ~ifelse(nchar(.)==0, NA, .)) %>%
    numerise_columns() %>%
    filter(!is.na(id)) # No point keeping records with no ID. Typically very few.

  library(tidyverse)
  glimpse(table_AE2)

  return(table_AE2)

  # Remove from memory
  rm(table_AE2)

}

