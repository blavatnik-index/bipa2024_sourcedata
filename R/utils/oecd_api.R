# OECD API calers

# get data from the OECD data API
oecd_api_data <- function(agency_identifier, dataflow_identifier,
                          dataflow_version, filter_expression, ..., out_file,
                          .base_url = NULL) {

  # base API url
  if (is.null(.base_url)) {
    .base_url <- "https://sdmx.oecd.org/public/rest/data/"
  }

  # one indicator at a time
  if (!rlang::is_scalar_character(dataflow_identifier)) {
    cli::cli_abort(c(x = "Please only request one {.arg dataflow_identifier} at a time"))
  }

  # create api call
  api_call <- paste(
    paste(agency_identifier, dataflow_identifier, dataflow_version, sep = ","),
    filter_expression,
    sep = "/"
  )

  # build request
  req <- httr2::request(.base_url) |>
    httr2::req_url_path_append(api_call) |>
    httr2::req_url_query(...) |>
    httr2::req_headers(
      Accept = "application/vnd.sdmx.data+csv; charset=utf-8; version=2"
    )

  # get a temporary file
  tmp_file <- tempfile(fileext = ".csv")

  # make the request, save the CSV
  httr2::req_perform(req, path = tmp_file)

  # copy out the CSV
  file.copy(tmp_file, out_file)

}

# get metadata from the OECD API
oecd_api_meta <- function(agency_identifier, dataflow_identifier,
                          dataflow_version, out_file, .base_url = NULL) {

  # base API url
  if (is.null(.base_url)) {
    .base_url <- "https://sdmx.oecd.org/public/rest/dataflow/"
  }

  # one indicator at a time
  if (!rlang::is_scalar_character(dataflow_identifier)) {
    cli::cli_abort(c(x = "Please only request one {.arg dataflow_identifier} at a time"))
  }

  req <- httr2::request(.base_url) |>
    httr2::req_url_path_append(
      agency_identifier, dataflow_identifier, dataflow_version
    ) |>
    httr2::req_url_query(references = "all")

  tmp_file <- tempfile(fileext = ".xml")

  httr2::req_perform(req, path = tmp_file)

  file.copy(tmp_file, out_file)

}

oecd_xml_metadata <- function(xml, write = TRUE) {

  if (is.character(xml)) {
    if (file.exists(xml)) {
      xml_xml <- xml2::read_xml(xml)
    } else {
      cli::cli_abort(c(
        x = "File does not exist",
        i = "Path: {.file {xml}}"
      ))
    }
  } else if (inherits(xml, "xml_document")) {
    xml_xml <- xml
  } else {
    cli::cli_abort(c(
      x = "Must pass file or xml2 node to {.arg}"
    ))
  }

  ns <- xml2::xml_ns(xml_xml)

  cl_nodes <- xml_xml |>
    xml2::xml_find_all(
      "message:Structures/structure:Codelists/structure:Codelist"
    )

  code_lists <- xml2::xml_attr(cl_nodes, "id", ns)

  code_lists_nm <- cl_nodes |>
    xml2::xml_find_all("common:Name[@xml:lang='en']", ns = ns) |>
    xml2::xml_text()

  code_list_meta <- tibble::tibble(
    code_list = code_lists,
    code_list_nm = code_lists_nm,
    agency_id = xml2::xml_attr(cl_nodes, "agencyID", ns),
    version = xml2::xml_attr(cl_nodes, "version", ns),
    is_final = xml2::xml_attr(cl_nodes, "isFinal", ns)
  )

  code_list_codes <- purrr::map(
    .x = cl_nodes,
    .f = ~.oecd_code_list(.x, ns)
  ) |>
    purrr::list_rbind()

  meta_out <- code_list_meta |>
    dplyr::left_join(code_list_codes, by = "code_list")

  if (write) {
    if (is.character(xml)) {
      out_file <- gsub("\\.xml$", ".csv", xml)
      readr::write_excel_csv(meta_out, out_file)
    cli::cli({
      cli::cli_alert_success("Metadata writen to file")
      cli::cli_alert_info("{.file {out_file}}")
    })
    } else {
      cli::cli_alert_warning(
        "{.arg xml} must be a file path if {.arg write} is {.val TRUE}"
      )
      return(meta_out)
    }
  } else {
    return(meta_out)
  }


}

.oecd_code_list <- function(node, ns) {

  cl_id <- xml2::xml_attr(node, "id", ns)

  code_nodes <- xml2::xml_find_all(node, "structure:Code")

  codes <- purrr::map(
    .x = code_nodes,
    .f = ~.oecd_code_extract(.x, ns)
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(code_list = cl_id, .before = 1)

}

# extract metadata components from downloaded XML
.oecd_code_extract <- function(node, ns) {

  tibble::tibble(
    code_value = xml2::xml_attr(node, attr = "id", ns  = ns),
    code_text = xml2::xml_text(xml2::xml_find_first(node, "common:Name[@xml:lang='en']"))
  )

}
