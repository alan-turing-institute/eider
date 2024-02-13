test_that("join_feature_tables", {
  # Read in and process some data
  filenames <- c("../data/ae2.csv")
  all_tables <- read_all_tables(filenames)

  feature_1 <- featurise_count(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = list(
      type = "or",
      subfilters = list(
        list(
          type = "in",
          column = "diagnosis_1",
          value = c(1)
        ),
        list(
          type = "in",
          column = "diagnosis_2",
          value = c(1)
        ),
        list(
          type = "in",
          column = "diagnosis_3",
          value = c(1)
        )
      )
    ),
    output_column_name = "feature_1_name",
    missing_value = 0
  )

  feature_76 <- featurise_count(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = list(
      type = "or",
      subfilters = list(
        list(
          type = "in",
          column = "diagnosis_1",
          value = c(76)
        ),
        list(
          type = "in",
          column = "diagnosis_2",
          value = c(76)
        ),
        list(
          type = "in",
          column = "diagnosis_3",
          value = c(76)
        )
      )
    ),
    output_column_name = "feature_76_name",
    missing_value = 0
  )

  # Join the feature tables
  joined_feature_table <- join_feature_tables(list(feature_1, feature_76))

  # Check the result
  expect_equal(joined_feature_table$id, 1)
  expect_equal(joined_feature_table$feature_1_name, 3)
  expect_equal(joined_feature_table$feature_76_name, 1)
})
