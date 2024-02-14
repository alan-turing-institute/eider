test_that("filter_greater_than", {
  filtered_data <- filter_all(
    iris,
    list(
      type = "greater_than",
      value = 5,
      column = "Sepal.Length"
    )
  )
  expect_true(all(filtered_data$passed$Sepal.Length > 5))
})
