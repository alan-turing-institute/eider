# Adjust date formats to DD-MM-YYYY
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
