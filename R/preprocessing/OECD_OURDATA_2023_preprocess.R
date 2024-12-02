
# OECD OUR Data report pdf URL
our_pdf <- "data_raw/OECD/OECD_OUR_2023/oecd_our_2023.pdf"

# read PDF file
our_raw <- pdftools::pdf_data(our_pdf)

# process PDF file
our_proc <- our_raw |>
  # get rows with data tables
  dplyr::bind_rows(.id = "page") |>
  dplyr::mutate(page = as.numeric(page)) |>
  dplyr::filter(page > 23 & page < 27) |>
  dplyr::mutate(
    # set table identifiers
    tbl = dplyr::case_when(
      page == 24 & y > 240 & y < 720  ~ 1,
      page == 25 & y == 92 ~ 1,
      page == 25 & y > 197 & y < 689  ~ 2,
      page == 26 & y > 136 & y < 635  ~ 3,
      TRUE ~ NA_integer_
    ),
    # set table columns
    col = dplyr::case_when(
      x < 100 ~  "cc_iso3c",
      tbl == 1 & x < 243 ~  "availability_policy",
      tbl == 1 & x < 398 ~  "availability_release",
      tbl == 1 & x < 463 ~  "availability_implementation",
      tbl == 1 & x >= 463 ~ "availability_score",
      tbl == 2 & x < 241 ~  "accessibility_policy",
      tbl == 2 & x < 408 ~  "accessibility_release",
      tbl == 2 & x < 467 ~  "accessibility_implementation",
      tbl == 2 & x >= 467 ~ "accessibility_score",
      tbl == 3 & x < 229 ~  "reuse_promotion",
      tbl == 3 & x < 352 ~  "reuse_dataliteracy",
      tbl == 3 & x < 414 ~  "reuse_monitoring",
      tbl == 3 & x >= 414 ~ "reuse_score"
    ),
    # convert country codes
    cc_iso3c = dplyr::if_else(col == "cc_iso3c", text, NA_character_),
    cc_iso3c = dplyr::case_match(
      cc_iso3c,
      "IRE" ~ "IRL", "ICE" ~ "ISL", "LTH" ~ "LTU",
      .default = cc_iso3c
    ),
    # coerce values to numeric
    value = dplyr::if_else(col == "cc_iso3c", NA_character_, text),
    value = as.numeric(value),
    # set reference year
    ref_year = 2022
  ) |>
  dplyr::filter(!is.na(tbl)) |>
  # fill country codes across table values
  dplyr::arrange(tbl, page, y, x) |>
  tidyr::fill(cc_iso3c) |>
  tidyr::drop_na(value) |>
  # drop OECD averages
  dplyr::filter(cc_iso3c != "OECD") |>
  dplyr::arrange(cc_iso3c, ref_year, tbl, col) |>
  dplyr::select(cc_iso3c, ref_year, variable = col, value)

# write raw dataset
readr::write_excel_csv(
  our_proc,
  "data_raw/OECD/OECD_OUR_2019/oecd_ourdata_2022.csv"
)