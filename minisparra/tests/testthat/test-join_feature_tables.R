make_filter <- function(diagnosis_value) {
  diag_1 <- list(
    type = "IN",
    column = "diagnosis_1",
    value = c(diagnosis_value)
  )
  diag_2 <- list(
    type = "IN",
    column = "diagnosis_2",
    value = c(diagnosis_value)
  )
  diag_3 <- list(
    type = "IN",
    column = "diagnosis_3",
    value = c(diagnosis_value)
  )
  list(
    type = "OR",
    subfilters = list(diag_1, diag_2, diag_3)
  )
}

test_that("join_feature_tables", {
  # Read in and process some data
  filenames <- c("../data/ae2.csv")
  all_tables <- read_all_tables(filenames)

  diag_101 <- featurise_count(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = make_filter(101),
    output_column_name = "diag_101_count",
    missing_value = 0
  )

  diag_102 <- featurise_count(
    all_tables = all_tables,
    source_table_file = "../data/ae2.csv",
    filter_obj = make_filter(102),
    output_column_name = "diag_102_count",
    missing_value = 0
  )

  # Join the feature tables
  joined_feature_table <- join_feature_tables(list(diag_101, diag_102))

  # Check the result
  expect_equal(joined_feature_table$id, c(1, 2))
  expect_equal(joined_feature_table$diag_101_count, c(4, 0))
  expect_equal(joined_feature_table$diag_102_count, c(2, 1))
})
