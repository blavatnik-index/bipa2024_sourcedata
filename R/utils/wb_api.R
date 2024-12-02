# WB API caller function

wb_api_call <- function(indicator, per_page = 1000, mrv = 1,
                        .base_url = NULL) {

  # base API url
  if (is.null(.base_url)) {
    .base_url <- "http://api.worldbank.org/v2/country/all/indicator/"
  }

  # one indicator at a time
  if (!rlang::is_scalar_character(indicator)) {
    cli::cli_abort(c(x = "Please only request one {.arg indicator} at a time"))
  }

  # build request
  req <- httr2::request(.base_url) |>
    httr2::req_url_path_append(indicator) |>
    httr2::req_url_query(format = "json", per_page = per_page, mrv = mrv) |>
    httr2::req_throttle(rate = 10/60)

  # make request, handle paginated response
  rp <- httr2::req_perform_iterative(
    req,
    next_req = httr2::iterate_with_offset(
      "page",
      resp_pages = function(resp) httr2::resp_body_json(resp)[[1]][["pages"]]
    )
  )

  # generate output tibble
  out <- purrr::map(
    .x = rp,
    .f = ~httr2::resp_body_json(.x)[[2]]
  ) |> purrr::list_flatten() |>
    purrr::map(
      .x = _,
      .f = ~tibble::tibble(
        ind_id = .x$indicator$id,
        ind_nm = .x$indicator$value,
        cty_id = .x$country$id,
        cty_nm = .x$country$value,
        cty_iso = .x$countryiso3code,
        date = .x$date,
        value = .x$value,
        unit = .x$unit,
        obs_sttus = .x$obs_status,
        decimal = .x$decimal
      )
    ) |>
    purrr::list_rbind()

  return(out)

}
