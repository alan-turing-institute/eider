ae2_table_name <- "../data/ae2.csv"

test_that("featurise_unique", {
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_1_unique <- featurise_unique(
    all_tables = all_tables,
    source_table_file = ae2_table_name,
    aggregate_column_name = "diagnosis_1",
    filter_obj = list(),
    output_column_name = "diag_1_unique",
    missing_value = 0
  )

  # Check the result
  orig_table <- read.csv(ae2_table_name)
  diag_1_unique_expected <- orig_table %>%
    group_by(id) %>%
    summarise(diag_1_unique = n_distinct(diagnosis_1)) %>%
    select(c(id, diag_1_unique))

  expect_equal(diag_1_unique$feature_table, diag_1_unique_expected)
})
