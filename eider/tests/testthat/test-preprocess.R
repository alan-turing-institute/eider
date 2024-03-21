smr04_data <- list(smr04 = eider_example("random_smr04_data.csv"))

# See vignettes for full example with patient 3 using these spec and data
with_preprocessing <- eider_example("spec_smr04_preprocessing.json")
without_preprocessing <- eider_example("spec_smr04.json")

test_that("preprocessing", {

  tf_with_preprocessing <- run_pipeline(
    data_sources = smr04_data,
    feature_filenames = with_preprocessing
  )

  tf_wout_preprocessing <- run_pipeline(
    data_sources = smr04_data,
    feature_filenames = without_preprocessing
  )

  tf_with_preprocessing <- tf_with_preprocessing$features
  tf_wout_preprocessing <- tf_wout_preprocessing$features

  # Check that with preprocessing patient 3 returns
  # 0 counts for the example data
  p3_w_preprocessing <- tf_with_preprocessing[tf_with_preprocessing$id == 3, ]
  expect_equal(p3_w_preprocessing$with_preprocessing, 0)

  # Check that without preprocessing patient 3 returns
  # 2 counts for the example data
  p3_no_preprocessing <- tf_wout_preprocessing[tf_wout_preprocessing$id == 3, ]
  expect_equal(p3_no_preprocessing$no_preprocessing, 2)

})
