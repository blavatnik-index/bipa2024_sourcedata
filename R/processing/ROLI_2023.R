
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read ROLI dataset
roli_raw <- tidyxl::xlsx_cells(
  "data_raw/ROLI_2023/2023_wjp_rule_of_law_index_HISTORICAL_DATA.xlsx",
  sheets = "Historical Data"
)

# extract columns of interest
roli_cols <- roli_raw |>
  dplyr::filter(row == 1) |>
  dplyr::mutate(
    character = stringr::str_trim(character),
    column = dplyr::case_when(
      character == "1.4 Government officials are sanctioned for misconduct" ~
        "roli_misconduct_sanctioned",
      character == "3.1. Publicized laws and government data" ~
        "roli_published_law",
      character == "3.2 Right to information" ~
        "roli_right_to_info",
      character == "3.4 Complaint mechanisms" ~
        "roli_complaint_mechanisms",
      character == "6.1 Government regulations are effectively enforced" ~
        "roli_regulations_enforced_effectively",
      character == "6.2 Government regulations are applied and enforced without improper influence" ~
        "roli_regulations_enforced_properly",
      character == "6.4 Due process is respected in administrative proceedings" ~
        "roli_process_respected",
      TRUE ~ NA_character_
    )
  ) |>
  tidyr::drop_na(column) |>
  dplyr::select(col, column)

# process ROLI data
roli_proc <- roli_raw |>
  dplyr::filter(row > 1) |>
  # set year and country values
  dplyr::mutate(
    year = dplyr::if_else(col == 2, numeric, NA_real_),
    country = dplyr::if_else(col == 4, character, NA_character_)
  ) |>
  # fill year and country across columns
  dplyr::arrange(row, col) |>
  dplyr::group_by(row) |>
  tidyr::fill(year, country, .direction = "down") |>
  dplyr::ungroup() |>
  # limit to latest data
  dplyr::filter(year == 2023) |>
  # merge column info
  dplyr::left_join(roli_cols, by = "col") |>
  # convert country names to codes
  dplyr::mutate(
    cc_iso3c = dplyr::if_else(country == "XKX", "XKK", country)
  ) |>
  tidyr::drop_na(column) |>
  dplyr::select(
    cc_iso3c, ref_year = year, variable = column, value = numeric
  )

# check all output codes are valid
check_codes(roli_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(roli_proc, "data_out/roli_2023.csv")

