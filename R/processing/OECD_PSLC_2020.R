
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read PSLC 2020 dataset
pslc20_raw <- readr::read_csv(
  "data_raw/OECD_PSLC_2020/GOV_2021_11062024184102117.csv"
)

# process PSLC data
pslc20_proc <- pslc20_raw |>
  janitor::clean_names() |>
  # exclude sub-categories and OECD average
  dplyr::filter(!grepl("_", ind) & cou != "OAVG") |>
  # generate variable names
  dplyr::mutate(
    variable = dplyr::case_match(
      ind,
      "UPRP" ~ "pslc_proactive_recruitment",
      "MSPS" ~ "pslc_senior_management",
      "DDGW" ~ "pslc_diverse_workforce"
    )
  ) |>
  dplyr::select(
    cc_iso3c = cou, ref_year = year, variable, value
  )

# check all output codes are valid
check_codes(pslc20_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(pslc20_proc, "data_out/oecd_pslc_2020.csv")
