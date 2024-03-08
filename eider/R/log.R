#' Log a TRACE message showing the current execution context
#'
#' @param context A character vector
#'
#' @returns NULL
trace_context <- function(context) {
  log_trace("context: ", stringr::str_c(context, collapse = " > "))
}

#' Concatenate context into string and append a message
#'
#' @param context A character vector
#' @param message A single string
#'
#' @returns result A single string
context_message <- function(context, message) {
  paste0(stringr::str_c(context, collapse = " > "), ": ", message)
}
