test_that("filter_less_than_equal", {
  filtered_data <- filter_less_than_equal(
    iris,
    list(
      type = "less_than_equal",
      value = 5,
      column = "Sepal.Length"
    )
  )
  expect_true(all(filtered_data$passed$Sepal.Length <= 5))
})
