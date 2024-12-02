# write standardised CSV
# this function takes a data.frame and checks that it conforms to standard
# requirements:
#   - data.frame has four columns named cc_iso3c, ref_year, variable and value
#   - the cc_iso3c column is a character vector with values comprising only
#     3 characters and all characters are upper case A-Z, validity of country
#     codes should be checked separately with the check_codes() function
#   - the ref_year column is a numeric vector with values only 4 digits in length
#   - the variable column is a character vector
#   - the value column is a numeric vector

write_standard_csv <- function(x, file, na = "", ...) {

  # check x is a data.frame
  if (!inherits(x, "data.frame")) {
    cli::cli_abort(c(
      "x" = "{.arg x} must be a data.frame"
    ))
  }

  # check file is a scalar character
  if (!rlang::is_scalar_character(file)) {
    cli::cli_abort(c(
      "x" = "{.arg file} must be a single character vector"
    ))
  }

  # set column names
  cols <- c("cc_iso3c", "ref_year", "variable", "value")

  # check x has required columns in order
  if (sum(names(x) == cols) != 4) {
    cli::cli_abort(c(
      "x" = "{.arg x} must have the columns {.arg {cols}} in that order"
    ))
  }

  # check country code is character, 3 characters, uses only A-Z
  if (!is.character(x$cc_iso3c)) {
    cli::cli_abort(c(
      "x" = "column {.arg cc_iso3c} in {.arg x} should be a character vector"
    ))
  } else {
    if (!(max(nchar(x$cc_iso3c)) == 3 & min(nchar(x$cc_iso3c) == 3))) {
      cli::cli_abort(c(
        "x" = "values in column {.arg cc_iso3c} in {.arg x} should be 3 characters long",
        "i" = "minimum character length: {min(nchar(x$cc_iso3c))}, maximum character length: {max(nchar(x$cc_iso3c))}"
      ))
    }
    if (sum(grepl("[^A-Z]", x$cc_iso3c)) > 0) {
      cli::cli_abort(c(
        "x" = "values in column {.arg cc_iso3c} in {.arg x} should only be upper case A-Z"
      ))
    }
  }

  # check reference year is numeric and 4 digits
  if (typeof(type.convert(x$ref_year, as.is = TRUE)) != "integer"){
    cli::cli_abort(c(
      "x" = "column {.arg ref_year} in {.arg x} should be an integer-ish vector",
      "i" = "{.arg ref_year} is either not a numeric vector or contains decimal values"
    ))
  } else {
    if (!(max(nchar(x$ref_year)) == 4 & min(nchar(x$ref_year)))) {
      cli::cli_abort(c(
        "x" = "values in column {.arg ref_year} in {.arg x} should be 4 digits",
        "i" = "minimum character length: {min(nchar(x$ref_year))}, maximum character length: {max(nchar(x$ref_year))}"
      ))
    }
  }

  # check variable is character
  if (!is.character(x$variable)) {
    cli::cli_abort(c(
      "x" = "column {.arg variable} in {.arg x} should be a character vector"
    ))
  }

  # check value is numeric
  if (!is.numeric(x$value)) {
    cli::cli_abort(c(
      "x" = "column {.arg value} in {.arg x} should be a numeric vector"
    ))
  }
  
  # write x to file
  readr::write_excel_csv(x, file, na = "", ...)

}