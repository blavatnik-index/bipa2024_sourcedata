
# processing requires a pre-processed dataset
# see ../preprocessing/OECD_IREG_2021_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read IRG dataset
ireg_raw <- readr::read_csv(
  "data_raw/OECD_IREG_2021/oecd_ireg_2021_indicators.csv"
)

# process IREG data
ireg_proc <- ireg_raw |>
  janitor::clean_names() |>
  # subset to latest data and remove supranational institutions/groupings
  dplyr::filter(time_period == max(time_period)) |>
  dplyr::filter(ref_area != "EU" & ref_area != "OECD_REP") |>
  dplyr::mutate(
    # flag if primary or secondary legislation
    legislation = dplyr::case_match(
      regulatory_category,
      "P" ~ "primary", "S" ~ "secondary"
    ),
    # set regulation component
    component = dplyr::case_match(
      measure,
      "RIA" ~ "ria", "SA" ~ "stakeholders", "EPE" ~ "evaluation"
    ),
    # generate variable name 
    variable = dplyr::if_else(
      is.na(legislation),
      NA_character_,
      paste("ireg", legislation, component, sep = "_")
    )
  )|>
  tidyr::drop_na(variable) |>
  dplyr::select(cc_iso3c = ref_area, ref_year = time_period, variable, value = obs_value)

# check all output codes are valid
check_codes(ireg_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(ireg_proc, "data_out/oecd_ireg_2021.csv")
