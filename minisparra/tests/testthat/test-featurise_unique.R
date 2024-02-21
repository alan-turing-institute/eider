ae2_table_name <- "../data/ae2.csv"

test_that("featurise_unique", {
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  diag_1_unique <- featurise(all_tables, "../spec/test_unique.json")

  # Check the result
  orig_table <- read.csv(ae2_table_name)
  diag_1_unique_expected <- orig_table %>%
    group_by(id) %>%
    summarise(diag_1_unique = n_distinct(diagnosis_1)) %>%
    select(c(id, diag_1_unique))

  expect_equal(diag_1_unique$feature_table, diag_1_unique_expected)
})
