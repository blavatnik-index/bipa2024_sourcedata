
# processing requires a pre-processed dataset
# see ../preprocessing/OECD_OURDATA_2023_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read OURDATA dataset
our_raw <- readr::read_csv(
  "data_raw/OECD_OURDATA_2023/oecd_ourdata_2023.csv"
)

# set output variable names
our_proc <- our_raw |>
  dplyr::mutate(
    variable = dplyr::case_match(
      variable,
      "availability_score" ~ "our_data_availability",
      "accessibility_score" ~ "our_data_accessibility",
      "reuse_score" ~ "our_data_reuse",
    )
  ) |>
  tidyr::drop_na(variable)

# check all output codes are valid
check_codes(our_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(our_proc, "data_out/oecd_ourdata_2022.csv")
