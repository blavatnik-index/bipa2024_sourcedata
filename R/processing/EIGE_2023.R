
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read spreadsheet as cells
eige_raw <- tidyxl::xlsx_cells(
  "data_raw/EIGE_2023/wmidm_adm_nat__wmid_natadmin.xlsx"
)

# get years metadata
eige_years <- eige_raw |>
  dplyr::filter(col > 1 & row == 20 & !is.na(character)) |>
  dplyr::mutate(
    ref_year = as.numeric(character)
  ) |>
  dplyr::select(col, ref_year)

# get countries metadata
eige_countries <- eige_raw |>
  dplyr::filter(col == 1 & row > 20 & !is.na(character)) |>
  # strip out aggregate values
  dplyr::filter(!grepl("^EEA|^European|^Instrument", character)) |>
  # convert country names to codes
  dplyr::mutate(
    cc_iso3c = countrycode::countrycode(
      character,
      origin = "country.name.en",
      destination = "iso3c",
      custom_match = c("Kosovo" = "XKK")
    )
  ) |>
  dplyr::select(row, cc_iso3c)

# process data
eige_proc <- eige_raw |>
  dplyr::filter(col > 1 & row > 20 & !is.na(numeric)) |>
  # set variable name, convert number to percentage
  dplyr::mutate(
    variable = "eige_senior_women",
    value = numeric/100
  ) |>
  # merge metadata
  dplyr::left_join(eige_years, by = "col") |>
  dplyr::left_join(eige_countries, by = "row") |>
  dplyr::filter(!is.na(cc_iso3c)) |>
  dplyr::filter(ref_year == max(ref_year), .by = cc_iso3c) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# check all output codes are valid
check_codes(eige_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(eige_proc, "data_out/eige_2023.csv")
