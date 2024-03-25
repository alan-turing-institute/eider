return_palceholder_feature <- function() {
  my_object <- list(
    source_file = "ae2.csv",
    transformation_type = "your_transformation_type",
    primary_filter = list(
      type = "AND",
      filter = list(
        subfilter_1 = list(
          data_column_name = "attendance_type",
          type = "IN",
          values = 7
        ),
        subfilter_2 = list(
          type = "OR",
          filter = list(
            subfilter_21 = list(
              data_column_name = "diagnosis_1",
              type = "IN",
              values = c(1, 2)
            ),
            subfilter_22 = list(
              data_column_name = "diagnosis_2",
              type = "IN",
              values = c(1, 2)
            ),
            subfilter_23 = list(
              data_column_name = "diagnosis_3",
              type = "IN",
              values = c(1, 2)
            )
          )
        ),
        subfilter_3 = list(
          data_column_name = "attendance_date",
          type = "GT_EQ",
          values = as.Date("2022-01-01")
        ),
        subfilter_4 = list(
          data_column_name = "attendance_date",
          type = "LT",
          values = as.Date("2024-02-01")
        )
      )
    )
  )
  return(my_object)
}
