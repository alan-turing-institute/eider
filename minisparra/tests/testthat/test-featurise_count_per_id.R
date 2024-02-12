test_that("featurise_count_per_id", {
  raw_ae2 <- read.csv("../data/ae2.csv")

  feature_1 <- featurise_count_per_id(
    ae2 = raw_ae2,
    target_diagnoses = 1,
    output_column_name = "feature_1_name"
  )

  feature_76 <- featurise_count_per_id(
    ae2 = raw_ae2,
    target_diagnoses = 76,
    output_column_name = "feature_76_name"
  )

  attendances_1 <- feature_1 %>%
    filter(id == 1) %>%
    pull(feature_1_name)

  attendances_76 <- feature_76 %>%
    filter(id == 1) %>%
    pull(feature_76_name)

  expect_equal(attendances_1, 3)
  expect_equal(attendances_76, 1)
})
