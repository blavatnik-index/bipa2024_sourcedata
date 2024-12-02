
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read VDEM dataset
vdem_raw <- readr::read_rds(
  "data_raw/VDEM_2023/V-Dem-CY-Full+Others-v14.rds"
)

# process VDEM data
vdem_proc <- vdem_raw |>
  tibble::as_tibble() |>
  # select latest data for each country
  dplyr::filter(year == max(year), .by = country_name) |>
  # convert country names to codes
  dplyr::mutate(
    cc_iso3c = suppressWarnings(countrycode::countrycode(
      country_name,
      origin = "country.name.en",
      destination = "iso3c",
      custom_match = c(
        "Kosovo" = "XKK", "Zanzibar" = "EAZ", "Somaliland" = "XSL",
        "Palestine/Gaza" = "XPG"
      )
    ))
  ) |>
  dplyr::filter(!is.na(cc_iso3c))

# generate output dataset
vdem_out <- vdem_proc |>
  # rename columns of interest
  dplyr::select(
    cc_iso3c,
    ref_year = year,
    vdem_favours = v2excrptps,
    vdem_theft = v2exthftps,
    vdem_impartial = v2clrspct,
    vdem_nepotism = v2stcritrecadm,
    vdem_jobs_econ = v2peasjsoecon,
    vdem_jobs_gender = v2peasjgen,
    vdem_jobs_location = v2peasjgeo,
    vdem_jobs_political = v2peasjpol,
    vdem_jobs_social = v2peasjsoc
  ) |>
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -ref_year), names_to = "variable", values_to = "value"
  ) |>
  tidyr::drop_na(value)

# check all output codes are valid
check_codes(vdem_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(vdem_out, "data_out/vdem_2023.csv")

# get electoral regime data (for contextual data)
vdem_regime <- vdem_proc |>
  dplyr::transmute(
    cc_iso3c,
    ref_year = year,
    vdem_regime = dplyr::case_match(
      v2x_regime, 0 ~ "Closed autocracy", 1 ~ "Electoral autocracy",
      2 ~ "Electoral democracy", 3 ~ "Liberal democracy"
    ),
    vdem_regime_num = v2x_regime
  )

# check all output codes are valid
check_codes(vdem_regime$cc_iso3c, .stop = TRUE, .success = FALSE)

# write regime dataset - wide format, do not check conformity
readr::write_excel_csv(vdem_regime, "data_context/vdem_regime.csv")
