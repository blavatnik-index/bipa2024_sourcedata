
# load utility functions
source("R/utils/country_codes.R")

# processing requires a pre-processed dataset
# see ../preprocessing/JURI_2018_preprocess.R

# get first row of dataaset
juri_headers <- readLines(
  "data_raw/JURI_2018/EN_index_edited.txt", n = 1
)

# get location of columns
juri_header_breaks <- stringi::stri_locate_all(juri_headers, regex = "\\s{2,}")[[1]]
juri_col_starts <- c(1, juri_header_breaks[, "end"] + 1)
juri_col_ends <- c(juri_header_breaks[, "end"], NA)

# read in dataset using column positions and clean column names
juri_raw <- readr::read_fwf(
  "data_raw/JURI_2018/EN_index_edited.txt",
  col_positions = readr::fwf_positions(
    start = juri_col_starts, end = juri_col_ends
  )
) |>
  janitor::row_to_names(1) |>
  janitor::clean_names()

# process dataset
juri_proc <- juri_raw |>
  dplyr::mutate(
    # correct typos in original source
    state = dplyr::case_match(
      state,
      "Benign" ~ "Benin", "Grenade" ~ "Grenada",
      .default = state
    ),
    # convert country names to codes
    cc_iso3c = countrycode::countrycode(
      state,
      origin = "country.name.en",
      destination = "iso3c",
      custom_match = c(
        "Kosovo" = "XKK",
        "Micronesia" = "FSM"
      )
    ),
    # derive general legal system information
    legal_system = dplyr::case_match(
      tolower(legal_system),
      "civil law" ~ "civil",
      "common law" ~ "common",
      "customary" ~ "customary",
      "mixed" ~ "mixed",
      "muslim law" ~ "islamic",
      NA ~ "transitional"
    ),
    # generate flags for all types of systems
    legal_civil = dplyr::case_when(
      legal_system == "civil" ~ TRUE,
      grepl("civil law", tolower(legal_system_details)) ~ TRUE,
      legal_system == "transitional" ~ NA,
      TRUE ~ FALSE
    ),
    legal_common = dplyr::case_when(
      legal_system == "common" ~ TRUE,
      grepl("common law", tolower(legal_system_details)) ~ TRUE,
      legal_system == "transitional" ~ NA,
      TRUE ~ FALSE
    ),
    legal_customary = dplyr::case_when(
      legal_system == "customary" ~ TRUE,
      grepl("customary", tolower(legal_system_details)) ~ TRUE,
      legal_system == "transitional" ~ NA,
      TRUE ~ FALSE
    ),
    legal_islamic = dplyr::case_when(
      legal_system == "islamic" ~ TRUE,
      grepl("muslim", tolower(legal_system_details)) ~ TRUE,
      legal_system == "transitional" ~ NA,
      TRUE ~ FALSE
    ),
    # generate federal flag
    federal_state = form_of_state == "Federal",
    # set government type (directorial only used in Switzerland and Bosnia,
    # for simplicity align with semi-presidential)
    government_type = dplyr::case_when(
      tolower(form_of_government) == "directorial" ~ "semi-presidential",
      tolower(form_of_government) == "semi-presidential" ~ "semi-presidential",
      tolower(form_of_government) == "monarchical" ~ "monarchy",
      tolower(form_of_government) == "parliamentary" ~ "parliamentary",
      tolower(form_of_government) == "presidential" ~ "presidential"
    ),
    # identify if proportional representation used
    pr_upper = grepl("prop", tolower(upper_house)),
    pr_lower = grepl("prop", tolower(lower_house)),
    pr_any = pr_upper | pr_lower,
    # set election type for upper house
    upper_house = dplyr::case_when(
      is.na(upper_house) ~ NA_character_,
      grepl("^Ind", upper_house) ~  "indirect election",
      grepl("^Maj", upper_house) ~  "majoritarian election",
      grepl("^Prop", upper_house) ~ "proportional election",
      grepl("^Nom", upper_house) ~  "appointed"
    ),
    # set election type for lower house
    lower_house = dplyr::case_when(
      is.na(lower_house) ~ NA_character_,
      lower_house == "Prop." ~ "directly elected (proportional)",
      lower_house == "Maj." ~ "directly elected (majoritarian)",
      lower_house == "Maj. + Prop." ~ "directly elected (mixed)",
      TRUE ~ "mixed system"
    ),
    # set general parliamentary type
    parliament_type = dplyr::case_when(
      is.na(upper_house) & is.na(lower_house) ~
        "no parliament",
      is.na(upper_house) & lower_house == "mixed system" ~
        "unicameral mixed parliament",
      is.na(upper_house) ~ "unicameral elected parliament",
      grepl("elect", upper_house) & grepl("elect", lower_house) ~
        "bicameral elected parliament",
      TRUE ~ "bicameral mixed parliament"
    ),
    # set type of state
    state_type = dplyr::case_when(
      government_type == "monarchy" ~ "monarchy",
      federal_state & grepl("presidential", government_type) ~
        "federal presidential",
      federal_state & grepl("parliamentary", government_type) ~
        "federal parliamentry",
      !federal_state & grepl("presidential", government_type) ~
        "unitary presidential",
      !federal_state & grepl("parliamentary", government_type) ~
        "unitary parliamentry",
      legal_system == "transitional" ~ "transistional state"
    )
  )

# create output dataset
juri_out <- juri_proc |>
   dplyr::select(
     cc_iso3c, legal_system, legal_civil, legal_common, legal_customary,
     legal_islamic, federal_state, government_type, state_type,
     parliament_type, lower_house, upper_house, pr_lower, pr_upper, pr_any
   ) |>
  dplyr::mutate(
    ref_year = 2018
  )

# check all output codes are valid
check_codes(juri_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset - wide format, do not check conformity
readr::write_excel_csv(juri_out, "data_context/juri_2018.csv", na = "")
