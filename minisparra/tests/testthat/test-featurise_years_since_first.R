test_that("featurise_years_since_first", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- c("../data/ae2.csv")
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_years_since_first(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = list(
      type = "or",
      subfilters = list(
        list(
          type = "in",
          column = "diagnosis_1",
          value = c(101)
        ),
        list(
          type = "in",
          column = "diagnosis_2",
          value = c(101)
        ),
        list(
          type = "in",
          column = "diagnosis_3",
          value = c(101)
        )
      )
    ),
    date_column_name = "time",
    cutoff_date = lubridate::ymd("2023-03-18"),
    output_column_name = "years_since_101_diag",
    missing_value = 40
  )

  years_since_first_101 <- diag_101$feature_table %>%
    filter(id == 1) %>%
    pull(years_since_101_diag)

  expect_equal(years_since_first_101, 7)
})
