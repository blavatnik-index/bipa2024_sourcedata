
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read flexible working dataset
flex_arr_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "OECD_PSLC_2022",
    "flexible-working-arrangements-in-central-government-2022_f89df3a2-en.xlsx"
  ),
  sheet = "g13-5"
)

# flexible working country codes
flex_arr_countries <- flex_arr_raw |>
  dplyr::filter(row > 30 & row < 247 & col == 1) |>
  dplyr::select(row, cc_iso3c = character)

# process flexible working data
flex_arr_proc <- flex_arr_raw |>
  # subset to value cells
  dplyr::filter(row > 30 & row < 247 & col > 1 & col < 13) |>
  tidyr::drop_na(character) |>
  dplyr::mutate(
    # column = dplyr::case_match(
    #   col,
    #   2 ~ "flexitime",
    #   4 ~ "part_time",
    #   6 ~ "compressed_week",
    #   8 ~ "trust_based_hours",
    #   10 ~ "remote_part_time",
    #   12 ~ "remote_full_time"
    # ),
    
    # encode categories
    value = dplyr::case_match(
      character,
      "All public employees are covered" ~ 1,
      "Most public employees covered (with some exemptions)" ~ 0.75,
      "Only some public employees" ~ 0.5,
      "Defined by ministry or service" ~ 0.5,
      "Not offered/ not applicable" ~ 0
    )
  ) |>
  dplyr::left_join(flex_arr_countries, by = "row") |>
  dplyr::summarise(value = sum(value, na.rm = TRUE), .by = cc_iso3c) |>
  dplyr::mutate(
    variable = "pslc_flexible_working",
    ref_year = 2022
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# read mobility availability data
mob_avl_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "OECD_PSLC_2022",
    "internal-lateral-mobility-in-central-government-2022_0bb64fee-en.xlsx"
  ),
  "g13-1"
)

# mobility availability country codes
mob_avl_countries <- mob_avl_raw |>
  dplyr::filter(row > 33 & row < 69 & (col == 1 | col == 4)) |>
  dplyr::mutate(col = col + 1) |>
  dplyr::select(row, col, cc_iso3c = character)

# process mobility availability data
mob_avl_proc <- mob_avl_raw |>
  # subset to data cells
  dplyr::filter(row > 33 & row < 69 & (col == 2 | col == 5)) |>
  dplyr::mutate(
    # set level
    column = dplyr::case_match(
      col,
      2 ~ "most_public_servants",
      5 ~ "senior_public_servants"
    ),
    # encode categories
    value = dplyr::case_match(
      character,
      "Mandatory/expected" ~ 1,
      "Recommended/encouraged" ~ 0.75,
      "Possible but not encouraged or recommended" ~ 0.5,
      "Not possible" ~ 0
    )
  ) |>
  dplyr::left_join(mob_avl_countries, by = c("row", "col")) |>
  dplyr::select(cc_iso3c, column, value)

# read forms of mobility dataset
mob_form_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "OECD_PSLC_2022",
    "use-of-forms-of-mobility-in-central-administrations-2022_31c0a77a-en.xlsx"
  ),
  "t13-2"
)

# forms of mobility country codes
mob_form_countries <- mob_form_raw |>
  dplyr::filter(((row > 4 & row < 40) | (row > 47 & row < 52)) & col == 2) |>
  dplyr::mutate(
    # convert country names to codes
    cc_iso3c = countrycode::countrycode(
      character,
      origin = "country.name.en",
      destination = "iso3c"
    )
  ) |>
  dplyr::select(row, cc_iso3c)

# process forms of mobility data
mob_form_proc <- mob_form_raw |>
  # subset to data cells
  dplyr::filter(row %in% mob_form_countries$row & col > 2 & col < 6) |>
  dplyr::mutate(
    # define columns
    column = dplyr::case_match(
      col,
      3 ~ "micro_assignment",
      4 ~ "short_assignment",
      5 ~ "secondment"
    ),
    
    # encode categories - each column has multiple values represented as
    # symbols using the Wingdings font: `n` if within the same employing
    # entity, `u` if to other entities in central government, `v` if to other
    # levels of government, `¤` if international (other countries or
    # international institutions)
    value = dplyr::case_when(
      # micro-assignment within entity, to other entities,
      #   to other government levels & internationally
      column == "micro_assignment" & character == "nuv¤" ~ 1,
      # micro-assignment within entity, to other entities &
      #   to other government levels
      column == "micro_assignment" & character == "nuv" ~ 1,
      # micro-assignment within entity, to other entities &
      #   internationally
      column == "micro_assignment" & character == "nu¤" ~ 1,
      # micro-assignment within entity and to other entities
      column == "micro_assignment" & character == "nu" ~ 1,
      # micro-assignement only within entity
      column == "micro_assignment" & character == "n" ~ 0.5,

      # short-term assignment within entity, to other entities,
      #   to other government levels & internationally
      column == "short_assignment" & character == "nuv¤" ~ 1,
      # short-term assignment within entity, to other entities,
      #   to other government levels & internationally
      column == "short_assignment" & character == "nuv¤" ~ 1,
      # short-term assignment within entity, to other entities &
      #   to other government levels
      column == "short_assignment" & character == "nuv" ~ 0.75,
      # short-term assignment within entity, to other entities &
      #   internationally
      column == "short_assignment" & character == "nu¤" ~ 0.75,
      # short-term assignment to other entities, to other government levels &
      #   internationally
      column == "short_assignment" & character == "uv¤" ~ 0.75,
      # short-term assignment to other entities & to other government levels
      column == "short_assignment" & character == "uv" ~ 0.75,
      # short-term assignment to other entities & internationally
      column == "short_assignment" & character == "u¤" ~ 0.75,
      # short-term assignment within entity & other entities
      column == "short_assignment" & character == "nu" ~ 0.5,
      # short-term assignment only to other entities
      column == "short_assignment" & character == "u" ~ 0.5,
      # short-term assignment only internationally
      column == "short_assignment" & character == "¤" ~ 0.5,
      # short-term assignment only within entity
      column == "short_assignment" & character == "n" ~ 0.25,

      # secondment within entity, to other entities,
      #   to other government levels & internationally
      column == "secondment" & character == "nuv¤" ~ 1,
      # secondment within entity, to other entities,
      #   to other government levels & internationally
      column == "secondment" & character == "nuv¤" ~ 1,
      # secondment within entity, to other entities &
      #   to other government levels
      column == "secondment" & character == "nuv" ~ 0.75,
      # secondment within entity, to other entities &
      #   internationally
      column == "secondment" & character == "nu¤" ~ 0.75,
      # secondment to other entities, to other government levels &
      #   internationally
      column == "secondment" & character == "uv¤" ~ 0.75,
      # secondment to other entities & to other government levels
      column == "secondment" & character == "uv" ~ 0.75,
      # secondment to other entities & internationally
      column == "secondment" & character == "u¤" ~ 0.75,
      # secondment within entity & other entities
      column == "secondment" & character == "nu" ~ 0.5,
      # secondment only to other entities
      column == "secondment" & character == "u" ~ 0.5,
      # secondment only internationally
      column == "secondment" & character == "¤" ~ 0.5,
      # secondment only within entity
      column == "secondment" & character == "n" ~ 0.25
    )
  ) |>
  dplyr::left_join(mob_form_countries, by = "row") |>
  dplyr::select(cc_iso3c, column, value)

# generate output mobility dataset
mobility_out <- mob_avl_proc |>
  dplyr::bind_rows(mob_form_proc) |>
  # sum availabilty and forms of mobility by country 
  dplyr::summarise(value = sum(value, na.rm = TRUE), .by = cc_iso3c) |>
  dplyr::mutate(
    variable = "pslc_mobility_practices",
    ref_year = 2022
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# get L&D strategies dataset
ld_strat_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "OECD_PSLC_2022",
    "learning-and-development-strategies-for-the-central-government-workforce-2022_2c221f7e-en.xlsx"
  ),
  "g13-3"
)

# process L&D strategies data
ld_strat_proc <- ld_strat_raw |>
  dplyr::filter(row > 27 & row < 65 & col > 1 & col < 4) |>
  dplyr::mutate(
    column = dplyr::case_match(
      col,
      2 ~ "cc_iso3c",
      3 ~ "value"
    ),
    # encode values
    value = dplyr::case_match(
      character,
      "Central strategy/plan and most ministries or agencies have their own training strategy/plan" ~
        "1",
      "Central strategy/plan and some ministries or agencies have their own training strategy/plan" ~
        "0.75",
      "Most ministries or agencies have their own training strategy/plan " ~ "0.75",
      "Only central strategy/plan" ~ "0.5",
      "Some ministries or agencies have their own training strategy/plan " ~ "0.25",
      .default = character
    )
  ) |>
  dplyr::select(row, column, value) |>
  tidyr::pivot_wider(
    names_from = column, values_from = value, id_cols = row
  ) |>
  dplyr::mutate(
    column = "ld_strat",
    value = as.numeric(value)
  ) |>
  dplyr::select(cc_iso3c, column, value)

# get L&D incentives dataset
ld_inctvs_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "OECD_PSLC_2022",
    "incentives-for-employee-learning-and-development-in-central-governments-2022_751da922-en.xlsx"
  ),
  "t13-4"
)

# L&D incentives countries
ld_inctvs_countries <- ld_inctvs_raw |>
  dplyr::filter(((row > 4 & row < 41) | (row > 44 & row < 50)) & col == 2) |>
  dplyr::mutate(
    # convert country names to codes
    cc_iso3c = countrycode::countrycode(
      character,
      origin = "country.name.en",
      destination = "iso3c"
    )
  ) |>
  dplyr::select(row, cc_iso3c)

# process L&D incentives data
ld_inctvs_proc <- ld_inctvs_raw |>
  dplyr::filter(row %in% ld_inctvs_countries$row & col > 2 & col < 9) |>
  dplyr::mutate(
    # define categories
    column = dplyr::case_match(
      col,
      3 ~ "employee_choice",
      4 ~ "additional_time",
      5 ~ "performance_evaluation",
      6 ~ "individual_plans",
      7 ~ "promotion_decisions",
      8 ~ "informal_feedback"
    ),
    # encode values - values are represented via Wingdings font, `l` is used
    # to denote "yes", `¡` is used to denote "no"
    value = dplyr::case_match(
      character,
      "l" ~ 1,
      "¡" ~ 0
    )
  ) |>
  dplyr::left_join(ld_inctvs_countries, by = "row") |>
  dplyr::select(cc_iso3c, column, value)

# generate L&D output data
learning_out <- ld_strat_proc |>
  dplyr::bind_rows(ld_inctvs_proc) |>
  # score is sum of strategies and incentives
  dplyr::summarise(value = sum(value, na.rm = TRUE), .by = cc_iso3c) |>
  dplyr::mutate(
    variable = "pslc_learning_development",
    ref_year = 2022
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# merge all data for output
pslc22_out <- flex_arr_proc |>
  dplyr::bind_rows(mobility_out, learning_out)

# check all output codes are valid
check_codes(pslc22_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(pslc22_out, "data_out/oecd_pslc_2022.csv")
