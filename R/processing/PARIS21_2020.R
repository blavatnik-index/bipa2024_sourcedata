
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read PARIS21 dataset
p21_raw <- readxl::read_xlsx("data_raw/PARIS21_2020/paris21_policydocuments.xlsx")

# process PARIS21 dataset
p21_proc <- p21_raw |>
  janitor::clean_names() |>
  # remove missing data
  dplyr::filter(!is.na(data_value) & data_value != "no data") |>
  dplyr::distinct(country, year, data_value) |>
  # subset to latest available year
  dplyr::filter(year == max(year), .by = country) |>
  # convert country names to codes, values to numeric, set variable name
  dplyr::mutate(
    cc_iso3c = countrycode::countrycode(
      country,
      origin = "country.name.en",
      destination = "iso3c"
    ),
    value = as.numeric(data_value),
    variable = "p21_statistics_usage"
  ) |>
  dplyr::select(cc_iso3c, ref_year = year, variable, value)

# check all output codes are valid
check_codes(p21_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(p21_proc, "data_out/paris21_2020.csv")
