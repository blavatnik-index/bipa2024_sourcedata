
# processing requires a pre-processed dataset
# see ../preprocessing/WB_WDI_2024_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read WDI dataset
wdi_raw <- readr::read_csv("data_raw/WB_WDI_2024/wb_wdi_2024.csv")

# process WDI data
wdi_proc <- wdi_raw |>
  # convert country codes, set variable names
  dplyr::mutate(
    cc_iso3c = dplyr::if_else(cty_iso == "XKX", "XKK", cty_iso),
    variable = dplyr::case_match(
      ind_id,
      # government expenditure as % of GDP
      "NE.CON.GOVT.ZS" ~    "wb_govt_spending",
      # total GDP, current USD
      "NY.GDP.MKTP.CD" ~    "wb_gdp_usd",
      # total GDP, adjusted for purchasing power parity
      "NY.GDP.MKTP.PP.CD" ~ "wb_gdp_ppp",
      # GDP per capita, current USD
      "NY.GDP.PCAP.CD" ~    "wb_gdppc_usd",
      # GDP per capita, adjusted for purchasing power parity
      "NY.GDP.PCAP.PP.CD" ~ "wb_gdppc_ppp",
      # total population
      "SP.POP.TOTL" ~       "wb_pop_total"
    )
  ) |>
  tidyr::drop_na(value) |>
  # select latest value for each country-variable pair
  dplyr::filter(
    date == max(date), .by = c(cc_iso3c, variable)
  ) |>
  # subset to countries in reference list
  dplyr::filter(cc_iso3c %in% cc_full_list$cc_iso3c) |>
  dplyr::select(cc_iso3c, ref_year = date, variable, value)

# check all output codes are valid
check_codes(wdi_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(wdi_proc, "data_context/wb_wdi_2024.csv")
