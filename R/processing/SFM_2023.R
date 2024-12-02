
# processing requires a pre-processed dataset
# see ../preprocessing/SFM_2023_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read SFM data
sfm_raw <- readr::read_csv("data_raw/SFM_2023/sfm_2023.csv")

# process SFM data
sfm_proc <- sfm_raw |>
  janitor::clean_names() |>
  # select indicator of interest
  dplyr::filter(indicator == "11.b.1") |>
  dplyr::filter(time_period == max(time_period), .by = "geo_area_code") |>
  # set variable name, convert country codes
  dplyr::mutate(
    variable = "sfm_ddr_strategies",
    cc_iso3c = countrycode::countrycode(geo_area_code, origin = "un",
                                        destination = "iso3c")
  ) |>
  dplyr::select(cc_iso3c, ref_year = time_period, variable, value)

# check all output codes are valid
check_codes(sfm_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(sfm_proc, "data_out/sfm_2023.csv")
