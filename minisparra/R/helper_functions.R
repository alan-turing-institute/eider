#' Adjust date formats to DD-MM-YYYY
#'
#' @export
adjust_date_format <- function(dx) {
  for (i in seq_len(dim(dx)[2])) {
    if (class(dx[1, i]) == "Date") {
      dx[, i] <- format(dx[, i], "%d-%m-%Y")
    }
  }
  dx
}

#' Used when we are adding sets of features one at a time to a single
#' data.frame

#' @param current_df data.frame with the current features (must include id
#' column). This can be NULL to start with.
#' @param new_df data.frame with the new features (must include id column). If
#' current_df is NULL current_df is assigned to new_df, otherwise a full join
#' is performed.
#' @param join_by column name to join by
#' @returns data.frame formed by joining
#' @export
join_feature_df <- function(current_df, new_df, join_by = "id") {
  if (is.null(current_df)) {
    new_df
  } else {
    current_df %>% dplyr::full_join(new_df, by = join_by)
  }
}
