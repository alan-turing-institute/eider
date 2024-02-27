ae2_table_name <- "../data/ae2.csv"

test_that("featurise_count", {
  # Read in data. Right now only one table but in principle we would have more
  # and we want to read them all in at the same time (with one function) to
  # avoid doing more work than necessary, hence this setup.
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)

  # This is a meaningless feature, but it is a serviceable test case
  diag_101 <- featurise(all_tables, "../spec/test_sum.json")

  # Check the result
  orig_table <- read.csv(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(diagnosis_1 == 101 | diagnosis_2 == 101 | diagnosis_3 == 101) %>%
    group_by(id) %>%
    summarise(diag_101_sum = sum(diagnosis_1)) %>%
    select(c(id, diag_101_sum))

  expect_equal(diag_101$feature_table, diag_101_expected)
})
