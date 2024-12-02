
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# get ISORA file names
isora_files <- dir("data_raw/ISORA_2021", pattern = ".*\\.xlsx",
                   full.names = TRUE)
names(isora_files) <- basename(isora_files)

# read ISORA spreadsheets
isora_raw <- purrr::map(
  .x = isora_files,
  .f = ~readxl::read_excel(.x, col_names = c("item", "country", "yr2018",
                                            "yr2019", "yr2020", "yr2021"))
) |>
  purrr::list_rbind(names_to =  "source")

# clean ISORA dataset
isora_proc <- isora_raw |>
  dplyr::mutate(
    # convert country names to codes
    cc_iso3c = countrycode::countrycode(
      country,
      origin = "country.name.en",
      destination = "iso3c",
      custom_match = c(
        "Kosovo, Republic of" = "XKK",
        "Republika Srpska" = "XRS"
      )
    ),
    # set interim variable names
    isora_variable = dplyr::case_match(
      item,
      # revenue
      "Total net revenue collected by the tax administration (in thousands in local currency)" ~
        "netrevenue_total_numeric",
      # expenditure
      "Total operating expenditures (in thousands in local currency)" ~
        "expenditure_total_numeric",
      "Total tax administrations operating expenditures (in thousands of local currency)" ~
        "expenditure_taxadmin_operating_total_numeric",
      "Total tax administrations operating expenditures (in thousands of local currency) -Calculated estimate" ~
        "expenditure_taxadmin_operating_total_estimate",
      # staffing
      "Staff strength levels -No. at start of FY" ~
        "fte_start_numeric",
      "Staff strength levels -Departures in FY" ~
        "fte_departures_numeric",
      "Staff strength levels -No. at end of FY" ~
        "fte_end_numeric",
      "Gender distribution (No. of staff at the end of FY)-All staff-Female" ~
        "fte_gender_female_all_numeric",
      "Gender distribution (No. of staff at the end of FY)-Executives only-Female" ~
        "fte_gender_female_execs_numeric",
      "Gender distribution (No. of staff at the end of FY)-All staff-Male" ~
        "fte_gender_male_all_numeric",
      "Gender distribution (No. of staff at the end of FY)-Executives only-Male" ~
        "fte_gender_male_execs_numeric",
      "Gender distribution (No. of staff at the end of FY)-All staff-Other" ~
        "fte_gender_other_all_numeric",
      "Gender distribution (No. of staff at the end of FY)-Executives only-Other" ~
        "fte_gender_other_execs_numeric",
      # filing
      "On-time return filing-Corporate income tax-No. of returns expected" ~
        "returns_corporate_expected_numeric",
      "On-time return filing-Personal income tax-No. of returns expected" ~
        "returns_personal_expected_numeric",
      "On-time return filing-Corporate income tax-No. of returns filed on time" ~
        "returns_corporate_ontime_numeric",
      "On-time return filing-Personal income tax-No. of returns filed on time" ~
        "returns_personal_ontime_numeric",
      "On-time filing rate % - Corporate income tax" ~
        "returns_corporate_ontime_rate",
      "On-time filing rate % - Personal income tax" ~
        "returns_personal_ontime_rate",
      # payment
      "On-time payments-Corporate income tax-Value of payments expected by due date (in thousands in local currency)" ~
        "payments_corporate_expected_numeric",
      "On-time payments-Personal income tax-Value of payments expected by due date (in thousands in local currency)" ~
        "payments_personal_expected_numeric",
      "On-time payments-Corporate income tax-Value of payments made on time (in thousands in local currency)" ~
        "payments_corporate_ontime_numeric",
      "On-time payments-Personal income tax-Value of payments made on time (in thousands in local currency)" ~
        "payments_personal_ontime_numeric",
      "On-time payment rate % - Corporate income tax" ~
        "payments_corporate_ontime_rate",
      "On-time payment rate % - Personal income tax" ~
        "payments_personal_ontime_rate",
      # arrears
      "Closing stock of arrears at year-end (in thousands in local currency)-Total arrears" ~
        "arrears_total_numeric",
      # service contacts
      "No. of incoming service contacts by channel-Online via taxpayer account" ~
        "service_contacts_onlineaccount_numeric",
      "No. of incoming service contacts by channel-Digital assistance (e.g. chat, digital assistant)" ~
        "service_contacts_digitalassistance_numeric",
      "No. of incoming service contacts by channel-Telephone call" ~
        "service_contacts_telephone_numeric",
      "No. of incoming service contacts by channel-E-mail" ~
        "service_contacts_email_numeric",
      "No. of incoming service contacts by channel-Mail / post" ~
        "service_contacts_mail_numeric",
      "No. of incoming service contacts by channel-In-person" ~
        "service_contacts_inperson_numeric",
      # returns by channel
      "Number of returns received by tax type and channel-Corporate income tax-Paper returns" ~
        "returns_corporate_paper_numeric",
      "Number of returns received by tax type and channel-Personal income tax-Paper returns" ~
        "returns_personal_paper_numeric",
      "Number of returns received by tax type and channel-Corporate income tax-Electronic returns-Fully pre-filled, deemed acceptance" ~
        "returns_corporate_electronic_electronic_prefill_accepted_numeric",
      "Number of returns received by tax type and channel-Personal income tax-Electronic returns-Fully pre-filled, deemed acceptance" ~
        "returns_personal_electronic_electronic_prefill_accepted_numeric",
      "Number of returns received by tax type and channel-Corporate income tax-Electronic returns-Fully pre-filled, confirmation required" ~
        "returns_corporate_electronic_prefill_confirmation_numeric",
      "Number of returns received by tax type and channel-Personal income tax-Electronic returns-Fully pre-filled, confirmation required" ~
        "returns_personal_electronic_prefill_confirmation_numeric",
      "Number of returns received by tax type and channel-Corporate income tax-Electronic returns-Partially pre-filled with income and/or expense information" ~
        "returns_corporate_electronic_prefill_partial_numeric",
      "Number of returns received by tax type and channel-Personal income tax-Electronic returns-Partially pre-filled with income and/or expense information" ~
        "returns_personal_electronic_prefill_partial_numeric",
      "Number of returns received by tax type and channel-Corporate income tax-Electronic returns-Not prefilled" ~
        "returns_corporate_electronic_noprefill_numeric",
      "Number of returns received by tax type and channel-Personal income tax-Electronic returns-Not prefilled" ~
        "returns_personal_electronic_noprefill_numeric",
      "Number of returns received by tax type and channel-Corporate income tax-Other" ~
        "returns_corporate_other_numeric",
      "Number of returns received by tax type and channel-Personal income tax-Other" ~
        "returns_personal_other_numeric",
      "Total number of returns received by tax type-Corporate income tax" ~
        "returns_corporate_total_numeric",
      "Total number of returns received by tax type-Personal income tax" ~
        "returns_personal_total_numeric",
      # e-payment
      "Percentage of payments received electronically-By number of payments" ~
        "payments_electronic_number_percent",
      "Percentage of payments received electronically-By value of payments" ~
        "payments_electronic_value_percent",
      # innovative practices
      "Administration uses behavioral insight methodologies or techniques" ~
        "innovation_bhvinsight_used",
      "Implementation and use of innovative technologies-Distributed ledger technology / Blockchain" ~
        "innovation_blockchain_used",
      "Implementation and use of innovative technologies-Artificial intelligence (AI), including machine learning" ~
        "innovation_aiml_used",
      "Implementation and use of innovative technologies-Cloud computing" ~
        "innovation_cloud_used",
      "Implementation and use of innovative technologies-Data science / analytics tools" ~
        "innovation_analytics_used",
      "Implementation and use of innovative technologies-Robotics Process Automation (RPA)" ~
        "innovation_automation_used",
      "Implementation and use of innovative technologies-Application programming interfaces(APIs)" ~
        "innovation_api_used",
      "Implementation and use of innovative technologies-Whole-of-government identification systems" ~
        "innovation_id_used",
      "Implementation and use of innovative technologies-Digital identification technology (e.g. biometrics, voice identification)" ~
        "innovation_idtech_used",
      "Implementation and use of innovative technologies-Virtual assistants (e.g. chatbots)" ~
        "innovation_virtualassistants_used"
    )
  ) |>
  dplyr::select(
    cc_iso3c, isora_variable, starts_with("yr")
  ) |>
  tidyr::drop_na(isora_variable) |>
  tidyr::pivot_longer(
    cols = c(-isora_variable, -cc_iso3c), names_to = "year"
  ) |>
  dplyr::mutate(
    # convert years to numeric
    year = as.numeric(gsub("yr", "", year)),
    # coerce non-numeric values to numeric
    num_value = dplyr::case_match(
      value,
      "D" ~ NA_character_,
      "N/A" ~ NA_character_,
      "Not Applicable" ~ NA_character_,
      "Yes" ~ "1",
      "InPlace" ~ "1",
      "Implementing" ~ "0.5",
      "Implmenting" ~ "0.5",
      "No" ~ "0",
      .default = value
    ),
    num_value = as.numeric(num_value)
  ) |>
  tidyr::drop_na(num_value) |>
  dplyr::select(-value)

# generate output dataset
isora_out <- isora_proc |>
  tidyr::pivot_wider(names_from = isora_variable, values_from = num_value) |>
  dplyr::mutate(
    # corporate filing rate
    isora_filing_corporate = returns_corporate_ontime_numeric /
      returns_corporate_expected_numeric,
    isora_filing_corporate = dplyr::if_else(
      is.na(isora_filing_corporate),
      returns_corporate_ontime_rate / 100,
      isora_filing_corporate
    ),
    # personal filing rate
    isora_filing_personal = returns_personal_ontime_numeric /
      returns_personal_expected_numeric,
    isora_filing_personal = dplyr::if_else(
      is.na(isora_filing_personal),
      returns_personal_ontime_rate / 100,
      isora_filing_personal
    ),
    # corporate payment rate
    isora_payments_corporate = payments_corporate_ontime_numeric /
      payments_corporate_expected_numeric,
    isora_payments_corporate = dplyr::if_else(
      is.na(isora_payments_corporate), payments_corporate_ontime_rate/100,
      isora_payments_corporate
    ),
    # personal payment rate
    isora_payments_personal = payments_personal_ontime_numeric /
      payments_personal_expected_numeric,
    isora_payments_personal = dplyr::if_else(
      is.na(isora_payments_personal), payments_personal_ontime_rate/100,
      isora_payments_personal
    ),
    # corporate e-filing
    int_total_corporate_returns = dplyr::if_else(
      returns_corporate_total_numeric == 0,
      returns_corporate_paper_numeric +
        returns_corporate_electronic_electronic_prefill_accepted_numeric +
        returns_corporate_electronic_prefill_confirmation_numeric	+
        returns_corporate_electronic_prefill_partial_numeric +
        returns_corporate_electronic_noprefill_numeric +
        returns_corporate_other_numeric,
      returns_corporate_total_numeric
    ),
    use_total_corporate_returns = dplyr::case_when(
      int_total_corporate_returns == 0 & returns_corporate_total_numeric == 0 ~
        NA_real_,
      int_total_corporate_returns > returns_corporate_total_numeric ~
        int_total_corporate_returns,
      TRUE ~ returns_corporate_total_numeric
    ),
    isora_electronic_corporate = (
      returns_corporate_electronic_electronic_prefill_accepted_numeric +
         returns_corporate_electronic_prefill_confirmation_numeric	+
         returns_corporate_electronic_prefill_partial_numeric +
         returns_corporate_electronic_noprefill_numeric
    ) / use_total_corporate_returns,
    # personal e-filing
    int_total_personal_returns = dplyr::if_else(
      returns_personal_total_numeric == 0,
      returns_personal_paper_numeric +
        returns_personal_electronic_electronic_prefill_accepted_numeric +
        returns_personal_electronic_prefill_confirmation_numeric	+
        returns_personal_electronic_prefill_partial_numeric +
        returns_personal_electronic_noprefill_numeric +
        returns_personal_other_numeric,
        returns_personal_total_numeric
    ),
    use_total_personal_returns = dplyr::case_when(
      int_total_personal_returns == 0 & returns_personal_total_numeric == 0 ~
        NA_real_,
      int_total_personal_returns > returns_personal_total_numeric ~
        int_total_personal_returns,
      TRUE ~ returns_personal_total_numeric
    ),
    isora_electronic_personal = (
      returns_personal_electronic_electronic_prefill_accepted_numeric +
        returns_personal_electronic_prefill_confirmation_numeric	+
        returns_personal_electronic_prefill_partial_numeric +
         returns_personal_electronic_noprefill_numeric
    ) / use_total_personal_returns,
    # epayments
    isora_electronic_payments = dplyr::case_when(
      is.na(payments_electronic_number_percent) &
        is.na(payments_electronic_value_percent) ~ NA_real_,
      !is.na(payments_electronic_number_percent) ~
        payments_electronic_number_percent / 100,
      !is.na(payments_electronic_value_percent) ~
        payments_electronic_value_percent / 100,
      TRUE ~ NA_real_
    ),
    # admin costs
    isora_admin_costs = dplyr::case_when(
      is.na(netrevenue_total_numeric) ~ NA_real_,
      netrevenue_total_numeric == 0 ~ NA_real_,
      !is.na(expenditure_taxadmin_operating_total_numeric) &
        expenditure_taxadmin_operating_total_numeric > 0 ~
        expenditure_taxadmin_operating_total_numeric /
        netrevenue_total_numeric,
      !is.na(expenditure_taxadmin_operating_total_estimate) &
        expenditure_taxadmin_operating_total_estimate > 0 ~
        expenditure_taxadmin_operating_total_estimate /
        netrevenue_total_numeric,
      TRUE ~ NA_real_
    ),
    # tax debt
    isora_tax_debt = dplyr::if_else(
      arrears_total_numeric == 0, NA_real_,
      arrears_total_numeric / netrevenue_total_numeric,
    ),
    # service contacts
    across(starts_with("service_contacts"), ~tidyr::replace_na(.x, 0)),
    service_contacts_total = service_contacts_onlineaccount_numeric +
      service_contacts_digitalassistance_numeric +
      service_contacts_telephone_numeric +
      service_contacts_email_numeric +
      service_contacts_mail_numeric +
      service_contacts_inperson_numeric,
    isora_digital_contacts = dplyr::if_else(
      service_contacts_total == 0, NA_real_,
      (service_contacts_onlineaccount_numeric +
         service_contacts_digitalassistance_numeric) /
        service_contacts_total
    ),
    # gender diversity
    across(starts_with("fte_gender"), ~tidyr::replace_na(.x, 0)),
    fte_gender_all_total = fte_gender_female_all_numeric +
      fte_gender_male_all_numeric + fte_gender_other_all_numeric,
    isora_fte_female = dplyr::if_else(
      fte_gender_all_total == 0,
      NA_real_,
      fte_gender_female_all_numeric / fte_gender_all_total
    ),
    fte_gender_execs_total = fte_gender_female_execs_numeric +
      fte_gender_male_execs_numeric + fte_gender_other_execs_numeric,
    isora_execs_female = dplyr::if_else(
      fte_gender_execs_total == 0,
      NA_real_,
      fte_gender_female_execs_numeric / fte_gender_execs_total
    ),
    # turnover
    isora_fte_turnover = fte_departures_numeric / (
      (fte_start_numeric + fte_end_numeric) / 2
    ),
    # get rid of > 100% rates for filing payments and contacts
    across(
      c(isora_filing_corporate, isora_filing_personal,
        isora_payments_corporate, isora_payments_personal,
        isora_electronic_corporate, isora_electronic_personal,
        isora_electronic_payments, isora_digital_contacts),
      ~dplyr::if_else(.x > 1, NA_real_, .x)
      )
  ) |>
  dplyr::select(cc_iso3c, year, starts_with("isora")) |>
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -year),
    names_to = "variable",
    values_to = "value"
  ) |>
  dplyr::mutate(
    # exclude extreme values
    keep = dplyr::case_when(
      # tax debt ratio to less than 3
      variable == "isora_tax_debt" & value < 3 ~ TRUE,
      variable == "isora_tax_debt" & value >= 3 ~ FALSE,
      # admin costs to 98th percentile
      variable == "isora_admin_costs" & value < 0.324 ~ TRUE,
      variable == "isora_admin_costs" & value >= 0.324 ~ FALSE,
      # turnover capped to less than 30%
      variable == "isora_fte_turnover" & value < 0.3 ~ TRUE,
      variable == "isora_fte_turnover" & value >= 0.3 ~ FALSE,
      # limit all other variables (i.e. proportions) to max of 1
      value <= 1 ~ TRUE,
      TRUE ~ FALSE
    )
  ) |>
  dplyr::filter(keep) |>
  # add innovation data
  dplyr::bind_rows(
    # get innovation variables, calculate sum of variables
    isora_proc |>
      dplyr::filter(grepl("innovation", isora_variable)) |>
      dplyr::summarise(
        value = sum(num_value, na.rm = TRUE),
        .by = c(cc_iso3c, year)
      ) |>
      dplyr::mutate(variable = "isora_innovative_practices") |>
      dplyr::select(cc_iso3c, year, variable, value)
  ) |>
  tidyr::drop_na(value) |>
  dplyr::filter(
    year == max(year),
    .by = c(cc_iso3c, variable)
  ) |>
  dplyr::filter(
    # filter out bosnian sub-national bodies - direct income taxes in
    # Bosnia & Herzegovina are handled at subnational level, federal level tax
    # authority only responsible for customs & some indirect taxes
    cc_iso3c != "XRS" & cc_iso3c != "BIH"
  ) |>
  dplyr::select(
    cc_iso3c, ref_year = year, variable, value
  )

# check all output codes are valid
check_codes(isora_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(isora_out, "data_out/isora_2021.csv")
