ae2_table_name <- "../data/ae2.csv"
cutoff_date <- lubridate::ymd("2023-03-18")
filter_obj <- list(
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
)

test_that("featurise_time_since (first,years)", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_time_since(
    all_tables = all_tables,
    source_table_file = ae2_table_name,
    filter_obj = filter_obj,
    date_column_name = "time",
    cutoff_date = cutoff_date,
    from_first = TRUE,
    time_units = "years",
    output_column_name = "years_since_first_101_diag",
    missing_value = 40
  )

  # Check the result
  orig_table <- read_one_table(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    mutate(
      years_since_first_101_diag =
        (cutoff_date - time) %/% lubridate::ddays(365.25)
    ) %>%
    group_by(id) %>%
    summarise(years_since_first_101_diag = max(years_since_first_101_diag)) %>%
    select(id, years_since_first_101_diag)

  expect_equal(diag_101$feature_table, diag_101_expected)
})

test_that("featurise_time_since (last,years)", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_time_since(
    all_tables = all_tables,
    source_table_file = ae2_table_name,
    filter_obj = filter_obj,
    date_column_name = "time",
    cutoff_date = cutoff_date,
    from_first = FALSE,
    time_units = "years",
    output_column_name = "years_since_last_101_diag",
    missing_value = 40
  )

  # Check the result
  orig_table <- read_one_table(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    mutate(
      years_since_last_101_diag =
        (cutoff_date - time) %/% lubridate::ddays(365.25)
    ) %>%
    group_by(id) %>%
    summarise(years_since_last_101_diag = min(years_since_last_101_diag)) %>%
    select(id, years_since_last_101_diag)

  expect_equal(diag_101$feature_table, diag_101_expected)
})

test_that("featurise_time_since (first,days)", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_time_since(
    all_tables = all_tables,
    source_table_file = ae2_table_name,
    filter_obj = filter_obj,
    date_column_name = "time",
    cutoff_date = cutoff_date,
    from_first = TRUE,
    time_units = "days",
    output_column_name = "days_since_first_101_diag",
    missing_value = 40
  )

  # Check the result
  orig_table <- read_one_table(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    mutate(
      days_since_first_101_diag =
        (cutoff_date - time) %/% lubridate::ddays(1)
    ) %>%
    group_by(id) %>%
    summarise(days_since_first_101_diag = max(days_since_first_101_diag)) %>%
    select(id, days_since_first_101_diag)

  expect_equal(diag_101$feature_table, diag_101_expected)
})
