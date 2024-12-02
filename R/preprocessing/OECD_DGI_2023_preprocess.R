
# set PDF URL
dgi_pdf <- "data_raw/OECD/OECD_DGI_2023/oecd_2023_digital_government_index_1a89ed5e-en.pdf"

# read PDF file
dgi_raw <- pdftools::pdf_data(dgi_pdf)

# process results table (page 26)
dgi_proc <- dgi_raw[[26]] |>
  # subset to table area
  dplyr::filter(y > 242 & y < 709) |>
  dplyr::mutate(
    # use x positions to infer table column
    col = dplyr::case_when(
      x < 90 ~ "cc_iso3c",
      x < 130 ~ "digital_design",
      x < 190 ~ "data_driven",
      x < 240 ~ "govt_as_platform",
      x < 300 ~ "open_default",
      x < 360 ~ "user_driven",
      x < 410 ~ "proactiveness",
      x < 470 ~ "composite_index",
      x >= 470 ~ "composite_rank",
    ),
    # set country code
    cc_iso3c = dplyr::if_else(col == "cc_iso3c", text, NA_character_),
    # identify values and coerce to numeric
    value = dplyr::if_else(col == "cc_iso3c", NA_character_, text),
    value = as.numeric(value),
    # set reference year
    ref_year = 2023
  ) |>
  # fill country codes across columns
  dplyr::arrange(y, x) |>
  tidyr::fill(cc_iso3c) |>
  # drop OECD average
  dplyr::filter(!is.na(value) & cc_iso3c != "OECD") |>
  dplyr::select(cc_iso3c, ref_year, variable = col, value)

# write raw data
readr::write_excel_csv(
  dgi_proc,
  "data_raw/OECD/OECD_DGI_2023/oecd_dgi_2023.csv"
)
