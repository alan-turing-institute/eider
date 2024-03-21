#' Log a message showing the current execution context
#'
#' @param context A character vector
#' @param severity A string in c("fatal", "error", "warn", "info", "debug",
#' "trace")
#'
#' @returns NULL
log_context <- function(context, severity) {
  logging_function <- switch(severity,
    "fatal" = log_fatal,
    "error" = log_error,
    "warn" = log_warn,
    "info" = log_info,
    "debug" = log_debug,
    "trace" = log_trace
  )
  logging_function("context: ", stringr::str_c(context, collapse = " > "))
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

trace_context <- function(context) {
  log_context(context, "trace")
}

debug_context <- function(context) {
  log_context(context, "debug")
}

info_context <- function(context) {
  log_context(context, "info")
}

warn_context <- function(context) {
  log_context(context, "warn")
}

error_context <- function(context) {
  log_context(context, "error")
}

fatal_context <- function(context) {
  log_context(context, "fatal")
}
