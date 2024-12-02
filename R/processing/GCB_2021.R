
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read africa dataset as cells
gcb_af_raw <- tidyxl::xlsx_cells(
  "data_raw/GCB/TI_GCB-AFRICA_2019/GCB Africa 2019 Country Full Results.xlsx",
  sheet = "Government Officials"
)

# process africa data
gcb_af_proc <- gcb_af_raw |>
  dplyr::filter(row > 3) |>
  dplyr::mutate(
    # set country names
    country = dplyr::if_else(col == 1, character, NA_character_),
    # set column names
    column = dplyr::case_match(
      col,
      2 ~ "corrupt_none",
      3 ~ "corrupt_some",
      4 ~ "corrupt_most",
      5 ~ "corrupt_all",
      6 ~ "corrupt_dk",
      7 ~ "corrupt_ref",
      8 ~ "corrupt_nonesome",
      9 ~ "corrupt_mostall"
    ),
    # set reference year
    ref_year = 2020
  ) |>
  # set country across columns
  dplyr::arrange(row, col) |>
  tidyr::fill(country) |>
  tidyr::drop_na(column) |>
  dplyr::select(country, ref_year, column, value = numeric)

# read asia dataset
gcb_as_raw <- haven::read_sav(
  "data_raw/GCB/TI_GCB-ASIA_2020/GCB_Edition10_Asia_2020.sav"
)

# process asia dataset
gcb_as_proc <- gcb_as_raw |>
  # convert variables of interest (factors to character, date to numeric year)
  dplyr::mutate(
    country = as.character(haven::as_factor(TCOUNTRY)),
    ref_year = max(lubridate::year(lubridate::dmy(END_DATE))),
    corrupt_officials = as.character(haven::as_factor(CORRPEOPLE3FIN))
  ) |>
  # calculate weighted percentage of corruption categories
  dplyr::count(country, ref_year, corrupt_officials, wt = WITHINWT) |>
  dplyr::mutate(pc = n/sum(n), .by = country) |>
  dplyr::mutate(
    # variable names for full range of categories
    column1 = dplyr::case_match(
      corrupt_officials,
      "None" ~ "corrupt_none",
      "Some of them" ~ "corrupt_some",
      "Most of them" ~ "corrupt_most",
      "All of them" ~ "corrupt_all",
      "Don't know/ Haven't heard" ~ "corrupt_dk",
      "Refused/ Don't want to answer" ~ "corrupt_refused"
    ),
    # variable names for combined categories
    column2 = dplyr::case_match(
      corrupt_officials,
      "None" ~ "corrupt_nonesome",
      "Some of them" ~ "corrupt_nonesome",
      "Most of them" ~ "corrupt_mostall",
      "All of them" ~ "corrupt_mostall",
    )
  )

# produce output dataset
gcb_as_out <- gcb_as_proc |>
  # full range scores
  dplyr::select(country, ref_year, column = column1, value = pc) |>
  # generate combined category scores, and append to dataset
  dplyr::bind_rows(
    gcb_as_proc |>
      tidyr::drop_na(column2) |>
      dplyr::summarise(pc = sum(pc), .by = c(country, ref_year, column2)) |>
      dplyr::select(country, ref_year, column = column2, value = pc)
  )

# read europe dataset
gcb_eu_raw <- haven::read_sav(
  "data_raw/GCB/TI_GCB-EU_2021/GCB_Edition10_EU_2021.sav"
)

# process europe dataset
gcb_eu_proc <- gcb_eu_raw |>
  # convert variables of interest (factors to character, date to numeric year)
  dplyr::mutate(
    country = as.character(haven::as_factor(COUNTRY)),
    ref_year = 2020,
    corrupt_officials = as.character(haven::as_factor(Q5_4))
  ) |>
  # calculate weighted percentage of corruption categories
  dplyr::count(country, ref_year, corrupt_officials, wt = WITHINWT) |>
  dplyr::mutate(pc = n/sum(n), .by = c(country)) |>
  dplyr::mutate(
    # variable names for full range of categories
    column1 = dplyr::case_match(
      corrupt_officials,
      "None" ~ "corrupt_none",
      "Some of them" ~ "corrupt_some",
      "Most of them" ~ "corrupt_most",
      "All of them" ~ "corrupt_all",
      "Don't know" ~ "corrupt_dk"
    ),
    # variable names for combined categories
    column2 = dplyr::case_match(
      corrupt_officials,
      "None" ~ "corrupt_nonesome",
      "Some of them" ~ "corrupt_nonesome",
      "Most of them" ~ "corrupt_mostall",
      "All of them" ~ "corrupt_mostall",
    )
  )

# produce output dataset
gcb_eu_out <- gcb_eu_proc |>
  # full range scores
  dplyr::select(country, ref_year, column = column1, value = pc) |>
  # generate combined category scores, and append to dataset
  dplyr::bind_rows(
    gcb_eu_proc |>
      tidyr::drop_na(column2) |>
      dplyr::summarise(pc = sum(pc), .by = c(country, ref_year, column2)) |>
      dplyr::select(country, ref_year, column = column2, value = pc)
  )

# get latin america and caribbean dataset
gcb_lc_raw <- tidyxl::xlsx_cells(
  "data_raw/GCB/TI_GCB-LAC_2019/GCB 2019 Americas Full Results.xlsx",
  sheet = "Government Officials"
)

# process LAC dataset
gcb_lc_proc <- gcb_lc_raw |>
  dplyr::filter(row > 1 & row < 20) |>
  dplyr::mutate(
    # set country names
    country = dplyr::if_else(col == 1, character, NA_character_),
    # set column names
    column = dplyr::case_match(
      col,
      2 ~ "corrupt_none",
      3 ~ "corrupt_some",
      4 ~ "corrupt_most",
      5 ~ "corrupt_all",
      6 ~ "corrupt_dk",
      7 ~ "corrupt_nonesome",
      8 ~ "corrupt_mostall"
    ),
    # set reference year
    ref_year = 2019
  ) |>
  # set country across columns
  dplyr::arrange(row, col) |>
  tidyr::fill(country) |>
  tidyr::drop_na(column) |>
  dplyr::select(country, ref_year, column, value = numeric)

# get middel east dataset
gcb_me_raw <- tidyxl::xlsx_cells(
  "data_raw/GCB/TI_GCB-MENA_2019/2019_GCB_MENA_Final_Results.xlsx",
  sheet = "Government Officials"
)

# process middle east dataset
gcb_me_proc <- gcb_me_raw |>
  dplyr::filter(row > 1 & row < 8) |>
  dplyr::mutate(
    # set country names
    country = dplyr::if_else(col == 1, character, NA_character_),
    # set column names
    column = dplyr::case_match(
      col,
      2 ~ "corrupt_none",
      3 ~ "corrupt_some",
      4 ~ "corrupt_most",
      5 ~ "corrupt_all",
      6 ~ "corrupt_dk",
      7 ~ "corrupt_nonesome",
      8 ~ "corrupt_mostall"
    ),
    # set reference year
    ref_year = 2019
  ) |>
  # fill country names across columns
  dplyr::arrange(row, col) |>
  tidyr::fill(country) |>
  tidyr::drop_na(column) |>
  dplyr::select(country, ref_year, column, value = numeric)

# get pacific dataset
gcb_pc_raw <- haven::read_sav(
  "data_raw/GCB/TI_GCB-PACIFIC_2021/GCBPacific_Final.sav"
)

# process pacific dataset
gcb_pc_proc <- gcb_pc_raw |>
  # convert variables of interest (factors to character, date to numeric year)
  dplyr::mutate(
    country = as.character(haven::as_factor(COUNTRY)),
    ref_year = max(lubridate::year(lubridate::ymd_hms(SECTION_D_END))),
    corrupt_officials = as.character(haven::as_factor(Q6_4))
  ) |>
  # calculate weighted percentage of corruption categories
  dplyr::count(country, ref_year, corrupt_officials, wt = WGTFAC) |>
  dplyr::mutate(pc = n/sum(n), .by = country) |>
  dplyr::mutate(
    # variable names for full range of categories
    column1 = dplyr::case_match(
      corrupt_officials,
      "None" ~ "corrupt_none",
      "Some of them" ~ "corrupt_some",
      "Most of them" ~ "corrupt_most",
      "All of them" ~ "corrupt_all",
      "Don’t know" ~ "corrupt_dk"
    ),
    # variable names for combined categories
    column2 = dplyr::case_match(
      corrupt_officials,
      "None" ~ "corrupt_nonesome",
      "Some of them" ~ "corrupt_nonesome",
      "Most of them" ~ "corrupt_mostall",
      "All of them" ~ "corrupt_mostall",
    )
  )

# produce output dataset
gcb_pc_out <- gcb_pc_proc |>
  # full range scores
  dplyr::select(country, ref_year, column = column1, value = pc) |>
  # generate combined category scores, and append to dataset
  dplyr::bind_rows(
    gcb_pc_proc |>
      tidyr::drop_na(column2) |>
      dplyr::summarise(pc = sum(pc), .by = c(country, ref_year, column2)) |>
      dplyr::select(country, ref_year, column = column2, value = pc)
  )

# generate combined output
gcb_out <-  dplyr::bind_rows(
  gcb_af_proc, gcb_as_out, gcb_eu_out, gcb_lc_proc, gcb_me_proc, gcb_pc_out
  ) |>
  # limit to latest data for country
  dplyr::filter(ref_year == max(ref_year), .by = country) |>
  # select variable of interest
  dplyr::filter(column == "corrupt_mostall") |>
  # set output variable name, convert country names to codes
  dplyr::mutate(
    variable = "gcb_corrupt_officials",
    cc_iso3c = countrycode::countrycode(
      country,
      origin = "country.name.en",
      destination = "iso3c",
      custom_match = c("FSM" = "FSM", "PNG" = "PNG")
    )
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# check all output codes are valid
check_codes(gcb_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(gcb_out, "data_out/gcb_2021.csv")
