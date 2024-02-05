test_that("featurise_count_per_id", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- c("../data/ae2.csv")
  all_tables <- read_all_tables(filenames)

  feature_1 <- featurise_count_per_id(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = list(
      type = "or",
      subfilters = list(
        list(
          type = "basic",
          column = "diagnosis_1",
          values = c(1)
        ),
        list(
          type = "basic",
          column = "diagnosis_2",
          values = c(1)
        ),
        list(
          type = "basic",
          column = "diagnosis_3",
          values = c(1)
        )
      )
    ),
    output_column_name = "feature_1_name",
    missing_value = 0
  )

  feature_76 <- featurise_count_per_id(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = list(
      type = "or",
      subfilters = list(
        list(
          type = "basic",
          column = "diagnosis_1",
          values = c(76)
        ),
        list(
          type = "basic",
          column = "diagnosis_2",
          values = c(76)
        ),
        list(
          type = "basic",
          column = "diagnosis_3",
          values = c(76)
        )
      )
    ),
    output_column_name = "feature_76_name",
    missing_value = 0
  )

  attendances_1 <- feature_1$feature_table %>%
    filter(id == 1) %>%
    pull(feature_1_name)

  attendances_76 <- feature_76$feature_table %>%
    filter(id == 1) %>%
    pull(feature_76_name)

  expect_equal(attendances_1, 3)
  expect_equal(attendances_76, 1)
})
