
# processing requires a pre-processed dataset
# see ../preprocessing/LPI_2022_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read LPI dataset
lpi_raw <- readr::read_csv("data_raw/LPI_2022/lpi_2022.csv")

# process LPI data
lpi_proc <- lpi_raw |>
  tidyr::drop_na(value) |>
  # limit to territories in reference list
  dplyr::filter(cty_iso %in% cc_full_list$cc_iso3c) |>
  # add variable name
  dplyr::mutate(
    variable = "lpi_customs_clearance"
  ) |>
  dplyr::select(
    cc_iso3c = cty_iso, ref_year = date, variable, value
  )

# check all output codes are valid
check_codes(lpi_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(lpi_proc, "data_out/lpi_2022.csv")
