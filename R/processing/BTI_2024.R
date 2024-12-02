
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read spreadsheet as cells
bti_raw <- tidyxl::xlsx_cells(
  "data_raw/BTI_2024/BTI_2024_Scores.xlsx"
)

# assign variable name to columns of interest
bti_vars <- bti_raw |>
  dplyr::filter(row == 1) |>
  dplyr::mutate(
    variable = dplyr::case_when(
      character == "  Q3.3 | Prosecution of office abuse" ~
        "bti_abuse_prosecuted",
      character == "  Q14.1 | Prioritization" ~
        "bti_govt_set_priorities",
      character == "  Q14.2 | Implementation" ~
        "bti_implement_policies",
      character == "  Q14.3 | Policy learning" ~
        "bti_innovative_flexible",
      character == "  Q15.1 | Efficient use of assets" ~
        "bti_resource_efficiency",
      character == "  Q15.2 | Policy coordination" ~
        "bti_policy_coordination",
      # character == "  Q15.3 | Anti-corruption policy" ~
      #   "bti_contain_corruption",
      character == "  Q16.4 | Public consultation" ~
        "bti_public_consultation",
      TRUE ~ NA_character_
    )
  ) |>
  tidyr::drop_na(variable) |>
  dplyr::select(
    col, variable
  )

# process raw data
bti_proc <- bti_raw |>
  # populate country names across columns
  dplyr::mutate(
    country = dplyr::if_else(col == 1, character, NA_character_),
  ) |>
  dplyr::arrange(row, col) |>
  dplyr::group_by(row) |>
  tidyr::fill(country) |>
  dplyr::ungroup() |>
  # drop cells without numeric values
  tidyr::drop_na(numeric) |>
  # match columns to variables of interest
  dplyr::filter(col %in% bti_vars$col & row > 1) |>
  dplyr::full_join(bti_vars, by = "col") |>
  # set reference year, convert country names to codes
  dplyr::mutate(
    ref_year = 2023,
    cc_iso3c = countrycode::countrycode(
      stringi::stri_trans_nfc(country),
      origin = "country.name.en",
      destination = "iso3c",
      custom_match = c("Kosovo" = "XKK")
    )
  ) |>
  dplyr::select(
    cc_iso3c, ref_year, variable, value = numeric
  )

# check all output codes are valid
check_codes(bti_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(bti_proc, "data_out/bti_2024.csv")
