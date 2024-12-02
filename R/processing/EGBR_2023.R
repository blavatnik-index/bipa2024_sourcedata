
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read services spreadsheet as cells
egbr_services_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "EGBR_2023",
    "6_eGovernment_Benchmark_2023__Final_Results_Bgn33TdFY2NnN7GOeUd64VCE84_98712.xlsx"
  )
)

# set metadata for service assessment data
egbr_services_meta <- egbr_services_raw |>
  dplyr::filter(
    sheet == "3b. Nat. Services - Data" & !is_blank & row > 6 & col > 2 & col < 13
  ) |>
  dplyr::mutate(
    # set column names
    column = dplyr::case_match(
      col,
      3 ~ "country",
      4 ~ "life_event",
      5 ~ "service",
      6 ~ "definition",
      7 ~ "type",
      8 ~ "target",
      9 ~ "govt_level",
      10 ~ "collection_year",
      11 ~ "service_provider",
      12 ~ "url"
    ),
    # merge character and numeric values
    value = dplyr::if_else(is.na(numeric), tolower(character), as.character(numeric))
  ) |>
  dplyr::select(row, column, value) |>
  tidyr::pivot_wider(names_from = column, values_from = value) |>
  dplyr::mutate(
    # relabel life-event
    life_event = dplyr::if_else(
      life_event == "business start-up", "startup", life_event
    ),
    # identify government level
    govt_level = dplyr::if_else(govt_level == "national", "central", govt_level)
  )

# process service assessment data
egbr_services_proc <- egbr_services_raw |>
  dplyr::filter(
    sheet == "3b. Nat. Services - Data" & !is_blank & row > 6 & col > 12 & col < 37
  ) |>
  dplyr::mutate(
    # assign individual assessments to groups
    column = dplyr::case_match(
      col,                          # alternate column name
      13 ~ "service_availability",  # a1_information_available
      14 ~ "service_availability",  # a2_service_avilable
      15 ~ "service_availability",  # a3_service_portal
      16 ~ "service_availability",  # a4_title
      17 ~ "service_availability",  # a5_breadcrumbs
      18 ~ "service_delivery",      # c1_completion_notice
      19 ~ "service_delivery",      # c2_progress_tracked
      20 ~ "service_delivery",      # c3_save_draft
      21 ~ "service_delivery",      # c4_expectations
      22 ~ "service_delivery",      # c5_timelines_clear
      23 ~ "service_delivery",      # c6_maximum_timeline
      24 ~ "service_delivery",      # c7_service_performance
      25 ~ "service_delivery",      # c8_error_message
      26 ~ "service_delivery",      # c9_visual_aids
      27 ~ "key_enablers",          # f1_authentication_reqs
      28 ~ "key_enablers",          # f2_online_authentication
      29 ~ "key_enablers",          # f3_national_id
      30 ~ "key_enablers",          # f4_single_signon
      31 ~ "key_enablers",          # f5_private_id
      32 ~ "key_enablers",          # f6_documenation_required
      33 ~ "key_enablers",          # f71_submit_document
      34 ~ "key_enablers",          # f72_obtain_document
      35 ~ "key_enablers",          # f8_personal_data_required
      36 ~ "key_enablers"           # f8_personal_data_prefilled
    ),
    # standardise values to 0/1
    character = tolower(character),
    value = dplyr::case_when(
      character == "yes" ~ 1L,
      character == "no" ~ 0L,
      numeric == 100 ~ 1L,
      numeric == 0 ~ 0L,
      TRUE ~ NA_integer_
    )
  ) |>
  dplyr::select(row, column, value) |>
  # calculate group scores for each website
  dplyr::summarise(count = sum(value, na.rm = TRUE), .by = c(row, column)) |>
  # standardise group scores to 0/1
  dplyr::mutate(
    value = dplyr::case_when(
      column == "service_availability" ~ count / 5,
      column == "service_delivery" ~ count / 9,
      column == "key_enablers" ~ count / 10,
      column == "mobile_friendliness" ~ count
    )
  ) |>
  # merge metadata, limit to central government websites
  dplyr::left_join(egbr_services_meta, by = "row") |>
  dplyr::filter(govt_level == "central") |>
  # split out information-only websites from service availability
  dplyr::mutate(
    group = dplyr::if_else(
      type == "informational",
      paste(life_event, "service_information", sep = "."),
      paste(life_event, column, sep = ".")
    )
  ) |>
  # generate country scores for each service group by life event
  dplyr::summarise(
    value = mean(value, na.rm = TRUE), .by = c(country, group)
  ) |>
  # strip life event 
  dplyr::mutate(
    group = gsub("^.*\\.", "", group)
  ) |>
  # generate country scores for each service group
  dplyr::summarise(
    value = mean(value, na.rm = TRUE),
    .by = c(country, group)
  ) |>
  # convert country codes, generate variable names and set reference year
  dplyr::mutate(
    cc_iso3c = countrycode::countrycode(
      country,
      origin = "eurostat",
      destination = "iso3c"
    ),
    variable = paste("egbr", group, sep = "_"),
    ref_year = 2022
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# get technical assessment data as cells
egbr_technical_raw <- tidyxl::xlsx_cells(
  file.path(
    "data_raw", "EGBR_2023",
    "7_eGovernment_Benchmark_2023__Nonscored_Indicators_p7bzcFp2z9UuHIKhwXtjloGEqOQ_98713.xlsx"
  )
)

# process technical assessments for security, findability and page speed
egbr_technical_proc <- egbr_technical_raw |>
  dplyr::mutate(
    # flag relevant data
    data_zone = dplyr::case_when(
      sheet == "1B. Web Security" & row > 13 ~ TRUE,
      sheet == "2B. Findability" & row > 12 ~ TRUE,
      sheet == "5B. Pagespeed" & row > 11 ~ TRUE,
      TRUE ~ FALSE
    ),
    # set column names
    column = dplyr::case_when(
      col == 2 ~ "country",
      sheet == "1B. Web Security" & col == 8 ~ "govt_level",
      sheet == "1B. Web Security" & col == 18 ~ "egbr_web_security",
      sheet == "1B. Web Security" & col == 30 ~ "url",
      sheet == "2B. Findability" & col == 9 ~ "url",
      sheet == "2B. Findability" & col == 10 ~ "egbr_findability",
      sheet == "5B. Pagespeed" & col == 8 ~ "govt_level",
      sheet == "5B. Pagespeed" & col == 10 ~ "url",
      sheet == "5B. Pagespeed" & col == 19 ~ "egbr_speed_interactive"
    ),
    # merge numeric and character values
    value = dplyr::if_else(is.na(numeric), tolower(character), as.character(numeric))
  ) |>
  # subset to relevant data and pivot
  dplyr::filter(data_zone) |>
  dplyr::select(sheet, row, column, value) |>
  tidyr::drop_na(column) |>
  tidyr::pivot_wider(names_from = column, values_from = value) |>
  dplyr::select(-row) |>
  # pivot back to long using variable names and drop missing values
  tidyr::pivot_longer(
    cols = c(-sheet, -country, -govt_level, -url),
    names_to = "variable", values_to = "value"
  ) |>
  tidyr::drop_na(value) |>
  # limit to central government (findability only conducted on central services)
  dplyr::mutate(
    govt_level = dplyr::if_else(
      sheet == "2B. Findability", "central", govt_level
    ),
    value = as.numeric(value)
  ) |>
  dplyr::filter(govt_level == "central") |>
  # de-duplicate dataset
  dplyr::distinct(country, url, variable, value) |>
  # calculate country scores for variables
  dplyr::summarise(
    value = mean(value, na.rm = TRUE),
    .by = c(country, variable)
  ) |>
  # set country codes and reference year
  dplyr::mutate(
    cc_iso3c = countrycode::countrycode(
      country, origin = "eurostat", destination = "iso3c"
    ),
    ref_year = 2022
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# generate metadata for accesibility assessments
egbr_accessbility_meta <- egbr_technical_raw |>
  dplyr::filter(
    sheet == "3B. Accessibility Foundations" & row > 13
  ) |>
  dplyr::mutate(
    character = tolower(character),
    # set column names
    column = dplyr::case_when(
      col == 2 ~ "country",
      sheet == "3B. Accessibility Foundations" & col == 8 ~ "govt_level",
      sheet == "3B. Accessibility Foundations" & col == 10 ~ "url"
    )
  ) |>
  tidyr::drop_na(column) |>
  dplyr::select(row, column, character) |>
  tidyr::pivot_wider(names_from = column, values_from = character) |>
  tidyr::drop_na(country)

# process accessibility assessments
egbr_accessbility_proc <- egbr_technical_raw |>
  dplyr::filter(
    sheet == "3B. Accessibility Foundations" & row > 13 & col > 11 & col < 20
  ) |>
  dplyr::mutate(
    # convert values to 0/1
    value = dplyr::case_match(
      character,
      "passes" ~ 1L, "violations" ~ 0L
    ),
    na_value = is.na(value)
  ) |>
  # generate accessibility scores per website
  dplyr::summarise(
    value = sum(value, na.rm = TRUE),
    na_value = sum(na_value),
    .by = row
  ) |>
  # strip value if website had no assessments
  dplyr::mutate(
    value = dplyr::if_else(na_value == 8, NA_integer_, value)
  ) |>
  # merge metadata and subset to central government services
  dplyr::left_join(egbr_accessbility_meta, by = "row") |>
  dplyr::filter(!is.na(country) & govt_level == "central") |>
  dplyr::distinct(country, url, value) |>
  # generate overall accessibility score for country
  dplyr::summarise(
    value = mean(value, na.rm = TRUE), .by = country
    ) |>
  # convert country codes, set reference year and variable name
  dplyr::mutate(
    cc_iso3c = countrycode::countrycode(
      country,
      origin = "eurostat",
      destination = "iso3c"
    ),
    ref_year = 2022,
    variable = "egbr_wcag_tests"
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value)

# combine egbr scores
egbr_out <- egbr_services_proc |>
  dplyr::bind_rows(egbr_technical_proc, egbr_accessbility_proc)

# check all output codes are valid
check_codes(egbr_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(egbr_out, "data_out/egbr_2022.csv")
