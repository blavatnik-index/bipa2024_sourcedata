
unsdg_api <- function(series_code, out_file, .base_url = NULL) {

  if (is.null(.base_url)) {
    .base_url <- "https://unstats.un.org/SDGAPI/v1/sdg/Series/DataCSV"
  }

  req_body <- paste0("seriesCodes=",series_code)

  req <- httr2::request(.base_url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(Accept = "application/octet-stream") |>
    httr2::req_body_raw(req_body, "application/x-www-form-urlencoded")

  resp <- httr2::req_perform(req)

  writeLines(
    httr2::resp_body_string(resp),
    out_file
  )

}
