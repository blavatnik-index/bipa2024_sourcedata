
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read QOG dataset
qog_raw <- readr::read_csv("data_raw/QOG_2020/qog_exp_agg_20.csv")

# process QOG data
qog_proc <- qog_raw |>
  # set country codes
  dplyr::mutate(
    cc_iso3c = dplyr::if_else(cname == "Hong Kong", "HKG", ccodealp)
  ) |>
  # select columns of interest
  dplyr::select(
    cc_iso3c,
    ref_year = year,
    qog_patronage = proff1,
    qog_merit = proff2,
    qog_tenure = proff3,
    qog_entry = close1,
    qog_interference = impar1,
    qog_impartial = impar2
  ) |>
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -ref_year),
    names_to = "variable", values_to = "value"
  ) |>
  tidyr::drop_na(value) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# check all output codes are valid
check_codes(qog_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(qog_proc, "data_out/qog_2020.csv")
