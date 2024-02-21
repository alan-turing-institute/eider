ae2_table_name <- "../data/ae2.csv"

test_that("featurise_count", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_count(
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
    output_column_name = "diag_101_count",
    missing_value = 0
  )

  # Check the result
  orig_table <- read.csv(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    group_by(id) %>%
    summarise(diag_101_count = n()) %>%
    select(c(id, diag_101_count))

  expect_equal(diag_101$feature_table, diag_101_expected)
})
