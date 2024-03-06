#' Log a TRACE message showing the current execution context
#'
#' @param context A character vector
#'
#' @returns NULL
trace_context <- function(context) {
  log_trace("context: ", stringr::str_c(context, collapse = " > "))
}
