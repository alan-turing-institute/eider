ae2_table_path <- "../data/ae2.csv"

test_that("featurise_count", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_path
  all_tables <- read_data(list(ae2 = ae2_table_path))

  diag_101 <- featurise(all_tables, "../spec/test_count.json")

  # Check the result
  orig_table <- read.csv(ae2_table_path)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    group_by(id) %>%
    summarise(diag_101_count = n()) %>%
    select(c(id, diag_101_count))

  expect_equal(diag_101$feature_table, diag_101_expected)
})
