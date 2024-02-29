ae2_table_name <- "../data/ae2.csv"

test_that("featurise_combine_min", {
  filenames <- ae2_table_name
  all_tables <- read_all_tables(filenames)
  spec <- json_to_feature("../spec/test_combine_min.json")
  combination <- featurise(all_tables, spec)

  # Calculate through standard means
  # First feature: Count of 101s in diagnosis_2
  expected_feat_1 <- read_one_table(ae2_table_name) %>%
    filter(diagnosis_2 == 101) %>%
    group_by(id) %>%
    summarise(count_of_101s_in_diag2 = n()) %>%
    select(id, count_of_101s_in_diag2)
  # Second feature: Sum of all values of diagnosis_1
  # This is obviously meaningless, but it's just for testing<
  expected_feat_2 <- read_one_table(ae2_table_name) %>%
    group_by(id) %>%
    summarise(sum_of_all_diag1 = sum(diagnosis_1)) %>%
    select(id, sum_of_all_diag1)
  # Combine the two features
  expected <- full_join(expected_feat_1, expected_feat_2, by = "id") %>%
    mutate(
      count_of_101s_in_diag2 =
        tidyr::replace_na(count_of_101s_in_diag2, 0)
    ) %>%
    mutate(sum_of_all_diag1 = tidyr::replace_na(sum_of_all_diag1, 0)) %>%
    mutate(my_min = pmin(count_of_101s_in_diag2, sum_of_all_diag1)) %>%
    select(id, my_min)

  # Check the result
  expect_equal(combination$feature_table, expected)
})
