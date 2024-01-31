# Adjust date formats to DD-MM-YYYY
#' @export
adjust_date_format <- function(dx) {
  for (i in 1:dim(dx)[2]) {
    if (class(dx[1, i]) == "Date") {
      dx[, i] <- format(dx[, i], "%d-%m-%Y")
    }
  }
  dx
}

#' @export
print_hello <- function(){
  print("Hello world")
}


join_feature_df <- function(current_df, new_df, join_by="id"){
  #' join_feature_df
  #' @description Used when we are adding sets of features one at a time to a
  #' single data.frame
  #' @param current_df data.frame with the current features (must include id column).
  #' This can be NULL to start with.
  #' @param new_df data.frame with the new features (must include id column). If current_df
  #' is NULL current_df is assigned to new_df, otherwise a full join is performed.
  #' @returns current_df data.frame formed by joining
  if (is.null(current_df)) {
    current_df <- new_df
  } else {
    current_df <- current_df %>%
      dplyr::full_join(new_df, by = join_by)
  }
  return(current_df)
}
