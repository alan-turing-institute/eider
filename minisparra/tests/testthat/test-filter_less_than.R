test_that("filter_less_than", {
  filtered_data <- filter_less_than(
    iris,
    list(
      type = "less_than",
      value = 5,
      column = "Sepal.Length"
    )
  )
  expect_true(all(filtered_data$passed$Sepal.Length < 5))
})
