
# read GDI PDF file
gci_pdf <- pdftools::pdf_data("data_raw/GCI_2020/D-STR-GCI.01-2021-PDF-E.pdf")

# convert to single data frame, select results pages
gci_data_pages <- gci_pdf |>
  dplyr::bind_rows(.id = "page") |>
  dplyr::mutate(
    page = as.numeric(page)
  ) |>
  dplyr::filter(
    page > 45 & page < 144
  )

# get country labels - country labels exist above graphs, but x/y position
# varies by page so try and coerce all text to country codes
gci_countries <- gci_data_pages |>
  dplyr::arrange(page, y, x) |>
  # add spaces to words if needed then merge all text on given row
  dplyr::mutate(
    text = dplyr::if_else(space, paste0(text, " "), text)
  ) |>
  dplyr::summarise(
    text = paste0(text, collapse = ""),
    .by = c(page, y)
  ) |>
  dplyr::mutate(
    # detect countries in all text
    cc_iso3c = suppressWarnings(
      countrycode::countrycode(
        text,
        origin = "country.name.en",
        destination = "iso3c"
      )
    ),
    # detect asterisks
    asterisks = gsub("^([^\\*]+)(\\*+)$", "\\2", text, perl = TRUE),
    asterisks = dplyr::if_else(
      grepl("\\*", asterisks),
      nchar(asterisks),
      NA_integer_
    )
  ) |>
  tidyr::drop_na(cc_iso3c) |>
  dplyr::select(page, y, cc_iso3c)

# process GDI pages
gci_proc <- gci_data_pages |>
  # identify text that has a decimal number
  dplyr::filter(grepl("^\\d{1,3}\\.\\d{2}$", text)) |>
  dplyr::select(
    page, x, y, text
  ) |>
  # merge country codes
  dplyr::mutate(cc_iso3c = NA_character_) |>
  dplyr::bind_rows(gci_countries) |>
  # sort by page, y, x to put country codes in front of their relevant data
  dplyr::arrange(page, y, x) |>
  # fill country codes against data
  tidyr::fill(cc_iso3c) |>
  tidyr::drop_na(text) |>
  # axis for Qatar graph is in decimal format so exclude
  dplyr::filter(!(page == 93 & y < 200)) |>
  # arrange by country and horizontal position
  dplyr::arrange(cc_iso3c, x) |>
  # generate position number for each value
  dplyr::mutate(col = dplyr::row_number(), .by = cc_iso3c) |>
  # convert values to numeric, set reference year, set variable names
  dplyr::mutate(
    value = as.numeric(text),
    ref_year = 2020,
    variable = dplyr::case_match(
      col,
      1 ~ "gci_overall",
      2 ~ "gci_legal_measures",
      3 ~ "gci_technical_measures",
      4 ~ "gci_organisational_measures",
      5 ~ "gci_capacity_development",
      6 ~ "gci_cooperative_measures"
    )
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# write preprocessed dataset back to raw folder
readr::write_excel_csv(gci_proc, "data_raw/GCI_2020/gci_2020.csv")
