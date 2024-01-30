##' Clean raw data and generate tidy versions of data tables. Will only update episodes table if force_redo = TRUE.
##'
##' @param force_redo Redo if clean data are not already there
##' @param dir_rawData directory containing raw data tables (from EHRs)
##' @param dir_cleanData directory to which clean data tables will be written
##' @returns NULL
##' @export
clean_rawData <- function(force_redo = TRUE,
                          dir_rawData = ".",
                          dir_cleanData = "."){
  library(lubridate)

  # Raw data files
  data_filenames <- c("Final_SMR00_extract_incl_UniqueStudyID.zsav",
                      "LOOKUP_SIMD_sex_dob_for_ATI.zsav")

  table_names <- c("SMR00","Patient_lookup")

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
  #             SMR00
  #---------------------------------
  smr00_filepath_clean <- file.path(dir_cleanData,"SMR00.fst")
  cat(paste0("... cleaning file: ", smr00_filepath_clean, "\n"))
  table_SMR00 <- haven::read_sav(file.path(dir_rawData, data_filenames[["SMR00"]]))
  library(tidyverse)
  glimpse(table_SMR00)

  # Parse the useful information
  table_SMR00 <- table_SMR00 %>%
    mutate(
      id = as.integer(UNIQUE_STUDY_ID),
      source_table = factor("SMR00", levels = source_names),
      source_row = as.integer(row_number()),
      date_of_birth = lubridate::dmy(DOB),
      gender = labelled::labelled(as.integer(SEX), c(Male =1, Female=2)),
      time = as_datetime(lubridate::dmy(CLINIC_DATE)),
      main_condition = as.character(MAIN_CONDITION)
    ) %>%
    select(-c(UNIQUE_STUDY_ID, DOB, CLINIC_DATE, SEX, MAIN_CONDITION)) %>%
    mutate_if(is.character, ~ifelse(nchar(.)==0, NA, .)) %>%
    numerise_columns() %>%
    filter(!is.na(id)) # No point keeping records with no ID. Typically very few.

  library(tidyverse)
  glimpse(table_SMR00)

  return(table_SMR00)

  # Save the parsed table to compressed RData
#  fst::write.fst(table_SMR00,path = smr00_filepath_clean, compress = 100)

  # Remove from memory
  rm(table_SMR00)
  gc()

}


clean_rawData()
