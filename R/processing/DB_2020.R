
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read dataset
db_raw <- haven::read_dta(
  "data_raw/DB_2020/Historical-data.dta"
)

# process data
db_proc <- db_raw |>
  dplyr::filter(!(cod %in% c(
    # drop city level data
    "BGD", "BGD_Chit", "BRA", "BRA_Rio", "BRN", "CHN", "CHN_Beij", "IDN",
    "IDN_Sura", "IND", "IND_Delh", "JPN", "JPN_Osak", "MEX", "MEX_Mont",
    "NGA", "NGA_Kano", "PAK", "PAK_Laho", "RUS", "RUS_Sai", "USA", "USA_Losa"
  ))) |>
  # relevant columns
  dplyr::select(cod, dbyear, taxestime) |>
  # filter out economies with no data, remove extreme outliers and limit to 
  # latest available data
  dplyr::filter(taxestime > 0 & taxestime < 590) |>
  dplyr::filter(dbyear == max(dbyear), .by = cod) |>
  # amend country codes to ISO standard
  dplyr::mutate(
    cc_iso3c = dplyr::case_when(
      cod == "BANG" ~ "BGD",
      cod == "BRAZ" ~ "BRA",
      cod == "CHIN" ~ "CHN",
      cod == "INDI" ~ "IND",
      cod == "INDO" ~ "IDN",
      cod == "JAP"  ~ "JPN",
      cod == "KSV"  ~ "XKK",
      cod == "MEXI" ~ "MEX",
      cod == "NIGE" ~ "NGA",
      cod == "PAKI" ~ "PAK",
      cod == "ROM"  ~ "ROU",
      cod == "RUSS" ~ "RUS",
      cod == "TMP"  ~ "TLS",
      cod == "US"   ~ "USA",
      cod == "WBG"  ~ "PSE",
      cod == "ZAR"  ~ "COD",
      TRUE ~ cod
    ),
    variable = "db_taxes_time"
  ) |>
  dplyr::select(
    cc_iso3c, ref_year = dbyear, variable, value = taxestime
  )

# check all output codes are valid
check_codes(db_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(db_proc, "data_out/db_2020.csv")
