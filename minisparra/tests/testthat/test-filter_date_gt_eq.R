ae2_table_name <- "../data/ae2.csv"

test_that("featurise_date_gt_eq", {
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)
  spec <- json_to_feature("../spec/test_dates_gt_eq.json")
  diag_101 <- featurise(all_tables, spec)

  # Check the result
  orig_table <- read_one_table(ae2_table_name)
  diag_101_expected <- orig_table %>%
    filter(time >= lubridate::ymd("2016-03-19")) %>%
    group_by(id) %>%
    summarise(diag_101_count = n()) %>%
    select(c(id, diag_101_count))

  expect_equal(diag_101$feature_table, diag_101_expected)
})
