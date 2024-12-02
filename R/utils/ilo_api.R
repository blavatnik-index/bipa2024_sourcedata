
# download bulk data files
ilo_api_download <- function(indicator, time_from = 2015, .base_url = NULL) {

  # base API url
  if (is.null(.base_url)) {
    .base_url <- "https://rplumber.ilo.org/data/indicator/"
  }

  # one indicator at a time
  if (!rlang::is_scalar_character(indicator)) {
    cli::cli_abort(c(x = "Please only request one {.arg indicator} at a time"))
  }

  # get a temporary file
  tmp_file <- tempfile(fileext = ".csv")

  # build request
  req <- httr2::request(.base_url) |>
    httr2::req_url_query(id = indicator, timefrom = time_from) |>
    httr2::req_throttle(10/60)

  # make request
  rp <- req |> httr2::req_perform(path = tmp_file)

  # move temporary file
  file.copy(
    tmp_file,
    file.path("data_raw", "ILOSTAT_2024", paste0(indicator, ".csv"))
  )

}

# download ILO data dictionaries
ilo_dic_download <- function(dictionary, .base_url = NULL) {

  # base API url
  if (is.null(.base_url)) {
    .base_url <- "https://rplumber.ilo.org/metadata/dic/"
  }

  # one indicator at a time
  if (!rlang::is_scalar_character(dictionary)) {
    cli::cli_abort(c(x = "Please only request one {.arg dictionary} at a time"))
  }

  # get a temporary file
  tmp_file <- tempfile(fileext = ".csv")

  # build request
  req <- httr2::request(.base_url) |>
    httr2::req_url_query(var = dictionary, lang = "en", format = ".csv") |>
    httr2::req_throttle(10/60)

  # make request
  rp <- req |> httr2::req_perform(path = tmp_file)

  # move temporary file
  file.copy(
    tmp_file,
    file.path("data_raw", "ILOSTAT_2024", paste0("dic_", dictionary, ".csv"))
  )

}