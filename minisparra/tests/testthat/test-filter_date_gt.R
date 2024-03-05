ae2_table_path <- "../data/ae2.csv"

test_that("featurise_date_gt", {
  all_tables <- read_data(list(ae2 = ae2_table_path))

  diag_101 <- featurise(all_tables, "../spec/test_dates_gt.json")

  # Check the result
  orig_table <- read_one_table(ae2_table_path)
  diag_101_expected <- orig_table %>%
    filter(time > lubridate::ymd("2016-03-19")) %>%
    group_by(id) %>%
    summarise(diag_101_count = n()) %>%
    select(c(id, diag_101_count))

  expect_equal(diag_101$feature_table, diag_101_expected)
})
