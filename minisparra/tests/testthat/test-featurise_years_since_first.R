ae2_table_name <- "../data/ae2.csv"
cutoff_date <- lubridate::ymd("2023-03-18")

test_that("featurise_years_since_first", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_years_since_first(
    all_tables = all_tables,
    source_table_file = ae2_table_name,
    filter_obj = list(
      type = "OR",
      subfilters = list(
        list(
          type = "IN",
          column = "diagnosis_1",
          value = c(101)
        ),
        list(
          type = "IN",
          column = "diagnosis_2",
          value = c(101)
        ),
        list(
          type = "IN",
          column = "diagnosis_3",
          value = c(101)
        )
      )
    ),
    date_column_name = "time",
    cutoff_date = cutoff_date,
    output_column_name = "years_since_101_diag",
    missing_value = 40
  )

  # Check the result
  orig_table <- read_one_table(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    mutate(
      years_since_101_diag =
        (cutoff_date - time) %/% lubridate::ddays(365.25)
    ) %>%
    group_by(id) %>%
    summarise(years_since_101_diag = max(years_since_101_diag)) %>%
    select(id, years_since_101_diag)

  expect_equal(diag_101$feature_table, diag_101_expected)
})
