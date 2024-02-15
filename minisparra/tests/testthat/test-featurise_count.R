test_that("featurise_count", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- c("../data/ae2.csv")
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_count(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
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
    output_column_name = "feature_1_name",
    missing_value = 0
  )

  diag_101_count <- diag_101$feature_table %>%
    filter(id == 1) %>%
    pull(feature_1_name)

  expect_equal(diag_101_count, 4)
})
