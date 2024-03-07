#' Issue an error with a context and stop
#'
#' @param err_message A string
#' @param context A character vector
#'
#' @returns NULL
error_context <- function(err_message, context) {
  ctx_str <- context %>%
    lapply(function(x) paste0(" > ", x)) %>%
    stringr::str_c(collapse = "\n")

  stop(err_message, "\nContext:\n", ctx_str, call. = FALSE)
}
