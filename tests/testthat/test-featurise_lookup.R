ae2_table_path <- "../data/ae2.csv"

# id,time,attendance_category,source_table,diagnosis_1,diagnosis_2,diagnosis_3
# 1,2016-03-17,1,AE2,101,NA,NA
# 1,2016-03-18,1,AE2,101,102,NA
# 1,2016-03-19,1,AE2,101,103,NA
# 1,2016-03-20,1,AE2,102,101,NA
# 2,2016-03-21,1,AE2,102,NA,NA

test_that("featurise_lookup", {
  all_tables <- read_data(list(ae2 = ae2_table_path))
  # This is a meaningless feature, but it is a serviceable test case
  diag_101 <- featurise(
    all_tables,
    json_to_feature("../spec/test_lookup.json")
  )

  # Check the result
  orig_table <- read.csv(ae2_table_path)
  diag_101_expected <- orig_table %>%
    group_by(id) %>%
    summarise(first_diagnosis = first(diagnosis_1)) %>%
    select(c(id, first_diagnosis))
  for (id_num in orig_table$id) {
    if (!id_num %in% diag_101_expected$id) {
      diag_101_expected <- diag_101_expected %>%
        dplyr::add_row(id = id_num, first_diagnosis = 0)
    }
  }

  expect_equal(diag_101$feature_table, diag_101_expected)
})
