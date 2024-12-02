
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read spreadsheet as individual cells
gtmi_raw <- tidyxl::xlsx_cells(
  "data_raw/GTMI_2022/WBG_GovTech Dataset_Mar2023.xlsx",
  sheets = "CG_GTMI_Data"
)

# set up metadata for processing
#   - columns:
#     - gtmi_baseq: column name in the World Bank source spreadsheet
#     - int_var: variable for initial processing
#     - variable: export variable
gtmi_vars_meta <- tibble::tribble(
  ~gtmi_baseq,    ~int_var,                   ~variable,
  "I-1",          "cloud",                    "gtmi_backend",
  "I-2",          "architecture1",            NA_character_,
  "I-2.4",        "architecture2",            NA_character_,
  "I-3",          "interoperability1",        NA_character_,
  "I-3.4",        "interoperability2",        NA_character_,
  "I-4",          "service_bus1",             NA_character_,
  "I-4.4",        "service_bus2",             NA_character_,
  "I-5",          "financial_mis1",           NA_character_,
  "I-5.6",        "financial_mis2",           NA_character_,
  "I-6",          "automated_banking",        "gtmi_admin",       # gtmi_fiscal
  "I-7",          "tax_mis",                  "gtmi_admin",       # gtmi_tax
  "I-8",          "customs_mis",              "gtmi_admin",       # gtmi_customs
  "I-9",          "hr_mis",                   "gtmi_admin",       # gtmi_hrm
  "I-10",         "payroll",                  "gtmi_admin",       # gtmi_hrm
  "I-12",         "eprocurement1",            NA_character_,
  "I-12.4",       "eprocurement2",            NA_character_,
  "I-12.5",       "open_contracting",         "gtmi_admin",       # gtmi_eprocurement
  "I-13",         "debt_mis",                 "gtmi_admin",       # gtmi_fiscal
  "I-14",         "pubinvst_mis",             "gtmi_admin",       # gtmi_fiscal
  "I-15",         "open_source",              "gtmi_policy",
  "I-17",         "innovation_tech",          "gtmi_innovation",
  "I-19",         "central_portal",           "gtmi_portals",
  "I-20",         "tax_portal1",              NA_character_,
  "I-20.2",       "tax_portal2",              NA_character_,
  "I-21",         "tax_efiling1",             NA_character_,
  "I-21.2",       "tax_efiling2",             NA_character_,
  "I-22",         "epayment1",                NA_character_,
  "I-22.2",       "epayment2",                NA_character_,
  "I-22.3",       "epayment_methods",         "gtmi_portals",
  "I-23",         "customs_portal1",          NA_character_,
  "I-23.2",       "customs_portal2",          NA_character_,
  "I-24",         "socsec_portal1",           NA_character_,
  "I-24.2",       "socsec_portal2",           NA_character_,
  "I-25",         "jobs_portal1",             NA_character_,
  "I-25.2",       "jobs_portal2",             NA_character_,
  "I-28",         "opengov_portal",           "gtmi_openness",  # gtmi_opendata
  "I-28.2",       "opengov_updates",          "gtmi_openness",  # gtmi_opendata
  "I-28.3",       "opengov_contents",         "gtmi_openness",  # gtmi_opendata
  "I-29",         "opendata_portal",          "gtmi_openness",  # gtmi_opendata
  "I-29.2",       "opendata_updates",         "gtmi_openness",  # gtmi_opendata
  "I-29.3",       "opendata_contents",        "gtmi_openness",  # gtmi_opendata
  "I-29.4",       "opendata_automated",       "gtmi_openness",  # gtmi_opendata
  "I-30",         "participation_portal",     "gtmi_engagement",
  "I-31",         "feedback_platforms",       "gtmi_engagement",
  "I-32",         "engagement_statistics",    "gtmi_engagement",
  "I-33",         "govtech_entity",           "gtmi_policy",
  "I-34",         "datagovernance_entity",    "gtmi_policy",
  "I-35",         "govtech_strategy",         "gtmi_policy",
  "I-36",         "govtech_wholegovt",        "gtmi_policy",
  # "I-37",         "right_to_info",            "gtmi_rti",
  "I-38",         "dataprivacy_law",          "gtmi_policy",
  "I-39",         "dataprivacy_authority",    "gtmi_policy",
  "I-42",         "digital_signature",        "gtmi_portals",
  "I-45",         "digital_skills",           "gtmi_policy",
  "I-46",         "innovation_strategy",      "gtmi_innovation",
  "I-47",         "innovation_entity",        "gtmi_innovation",
  "I-48",         "innovation_startups",      "gtmi_innovation",
  NA_character_,  "architecture",             "gtmi_backend",
  NA_character_,  "interoperability",         "gtmi_backend",
  NA_character_,  "service_bus",              "gtmi_backend",
  NA_character_,  "financial_mis",            "gtmi_admin",       # gtmi_fiscal
  NA_character_,  "eprocurement",             "gtmi_admin",       # gtmi_eprocurement
  NA_character_,  "tax_portal",               "gtmi_portals",     # gtmi_tax
  NA_character_,  "epayment",                 "gtmi_portals",
  NA_character_,  "customs_portal",           "gtmi_portals",     # gtmi_customs
  NA_character_,  "socsec_portal",            "gtmi_portals",     # gtmi_socsec
  NA_character_,  "jobs_portal",              "gtmi_portals"      # gtmi_socsec
) |>
  dplyr::mutate(
    key_var = tidyr::replace_na(!grepl("\\.", gtmi_baseq), TRUE)
  )

# find the relevant base questions in the raw data
gtmi_vars <- gtmi_raw |>
  dplyr::filter(row == 1) |>
  dplyr::inner_join(gtmi_vars_meta, by = c("character" = "gtmi_baseq")) |>
  dplyr::select(col, int_var, key_var)

# process the raw data
gtmi_proc <- gtmi_raw |>
  # filter to relevant rows (ignore summary/checking rows)
  dplyr::filter(row > 1 & row < 398) |>
  dplyr::mutate(
    # recode country codes
    cc_iso3c = dplyr::case_when(
      col == 2 & character == "KSV" ~ "XKK",
      col == 2 & character == "WBG" ~ "PSE",
      col == 2 ~ character,
      TRUE ~ NA_character_
    ),
    # extract the reference year
    ref_year = dplyr::if_else(col == 1, numeric, NA_real_),
    # identify if data is based on country submissions (S) or 'remote'
    # assessments by World Bank researchers (R)
    source_remote = dplyr::case_when(
      col == 355 & character == "R" ~ TRUE,
      col == 355 & character == "S" ~ FALSE,
      TRUE ~ NA
    )
  ) |>
  # spread country, ref_year and source info to all cells
  dplyr::arrange(row, col) |>
  dplyr::group_by(row) |>
  tidyr::fill(cc_iso3c, ref_year, source_remote, .direction = "downup") |>
  dplyr::ungroup() |>
  # extract just 2022 data
  dplyr::filter(ref_year == 2022) |>
  # merge variable info and subset to matched values and pivot
  dplyr::left_join(gtmi_vars, by = "col") |>
  tidyr::drop_na(int_var) |>
  dplyr::select(cc_iso3c, ref_year, int_var, numeric) |>
  tidyr::pivot_wider(names_from = int_var, values_from = numeric) |>
  # recode variables to 0-1 scale
  dplyr::mutate(
    # code no (0) as 0, code only strategy/policy or in draft/planned (1) as 0.5,
    # code yes/in use (2) as 1
    across(
      c(cloud, automated_banking, tax_mis, customs_mis, hr_mis, payroll,
        debt_mis, pubinvst_mis, innovation_tech,
        opendata_automated, govtech_entity, datagovernance_entity,
        govtech_wholegovt, dataprivacy_law,
        #right_to_info,
        dataprivacy_authority, innovation_entity),
      ~dplyr::case_match(.x, 0 ~ 0, 1 ~ 0.5, 2 ~ 1, .default = 0)
    ),
    # code no (0) as 0, code yes/in use but "limited" adoption (1) as 0.75,
    # code yes with wide adoption (2) as 1
    across(
      c(open_source, central_portal, opengov_contents, opendata_contents,
        opendata_automated, digital_skills,
        innovation_strategy),
      ~dplyr::case_match(.x, 0 ~ 0, 1 ~ 0.75, 2 ~ 1, .default = 0)
    ),
    # code no (0) as 0, code planned/in progress (1) as 0.5, code yes/in use
    # but limited adoption (2) as 0.75, code yes with wide adoption (3) as 1
    across(
      c(opengov_updates, opendata_updates, digital_signature),
      ~dplyr::case_match(.x, 0 ~ 0, 1 ~ 0.5, 2 ~ 0.75, 3 ~ 1, .default = 0)
    ),

    # code multi-question variables

    # epayment: code epayment via bank transfer and other methods (2, 3, 4) as
    # 1, code epayment by bank transfer only as 0.75, code no epayment methods
    # as 0
    epayment_methods = dplyr::case_when(
      epayment_methods > 1 ~ 1,
      epayment_methods == 1 ~ 0.75,
      TRUE ~ 0
    ),

    # architecture, interoperability & service bus - when used extensively code
    # as 1, when used partially code as 0.75, if in use but operational extent
    # unknown code as 0.75, when in planning code as 0.5, when not in use code
    # as 0

    architecture = dplyr::case_when(
      !is.na(architecture2) & architecture2 == 2 ~ 1,
      !is.na(architecture2) & architecture2 == 1 ~ 0.75,
      architecture1 == 2 ~ 0.75,
      architecture1 == 1 ~ 0.5,
      architecture1 == 0 ~ 0
    ),
    interoperability = dplyr::case_when(
      !is.na(interoperability2) & interoperability2 == 2 ~ 1,
      !is.na(interoperability2) & interoperability2 == 1 ~ 0.75,
      interoperability1 == 2 ~ 0.75,
      interoperability1 == 1 ~ 0.5,
      interoperability1 == 0 ~ 0
    ),
    service_bus = dplyr::case_when(
      !is.na(service_bus2) & service_bus2 == 2 ~ 1,
      !is.na(service_bus2) & service_bus2 == 1 ~ 0.75,
      service_bus1 == 2 ~ 0.75,
      service_bus1 == 1 ~ 0.5,
      service_bus1 == 0 ~ 0
    ),

    # portals/services - where a system provides a "full" experience code as 1,
    # where system provides a "partial" experience code as 0.75, if system
    # exists but full/partial can't be determined code as 0.75, if system is
    # being planned/implemented code as 0.5, if system does not exist code as 0.

    # FMIS
    #   - full: treasury (execution) & budget (preparation)
    #   - partial: treasury (execution) only
    financial_mis = dplyr::case_when(
      !is.na(financial_mis2) & financial_mis2  > 1 ~ 1,
      !is.na(financial_mis2) & financial_mis2 == 1 ~ 0.75,
      financial_mis1 == 2 ~ 0.75,
      financial_mis1 == 1 ~ 0.5,
      financial_mis1 == 0 ~ 0
    ),
    # eprocurement
    #   - full: tender notices and online contracting
    #   - partial: tender notices only
    eprocurement = dplyr::case_when(
      !is.na(eprocurement2) & eprocurement2  > 1 ~ 1,
      !is.na(eprocurement2) & eprocurement2 == 1 ~ 0.75,
      eprocurement1 == 2 ~ 0.75,
      eprocurement1 == 1 ~ 0.5,
      eprocurement1 == 0 ~ 0
    ),
    # tax portal and/or tax e-filing service
    #   - full: registration, filing and payment
    #   - partial: registration and filing only
    tax_portal = dplyr::case_when(
      !is.na(tax_portal2) & tax_portal2    > 1 ~ 1,
      !is.na(tax_efiling2) & tax_efiling2  > 1 ~ 1,
      !is.na(tax_portal2) & tax_portal2   == 1 ~ 0.75,
      !is.na(tax_efiling2) & tax_efiling2 == 1 ~ 0.75,
      tax_portal1  == 2 ~ 0.75,
      tax_efiling1 == 2 ~ 0.75,
      tax_portal1  == 1 ~ 0.5,
      tax_efiling1 == 1 ~ 0.5,
      tax_portal1  == 0 ~ 0,
      tax_efiling1 == 0 ~ 0
    ),
    # epayment
    #   - full: centralised epayment service shared across government
    #   - partial: fragmented/multiple epayment services
    epayment = dplyr::case_when(
      !is.na(epayment2) & epayment2 == 2 ~ 1,
      !is.na(epayment2) & epayment2 == 1 ~ 0.75,
      epayment1 == 2 ~ 0.75,
      epayment1 == 1 ~ 0.5,
      epayment1 == 0 ~ 0
    ),
    # customs portal:
    #   - full: registration, declaration and payment
    #   - partial: registration and declaration only
    customs_portal = dplyr::case_when(
      !is.na(customs_portal2) & customs_portal2  > 1 ~ 1,
      !is.na(customs_portal2) & customs_portal2 == 1 ~ 0.75,
      customs_portal1 == 2 ~ 0.75,
      customs_portal1 == 1 ~ 0.5,
      customs_portal1 == 0 ~ 0
    ),
    # social security portal
    #   - full: registration, benefits statements and payments
    #   - partial: registration and benefits statements only
    socsec_portal = dplyr::case_when(
      !is.na(socsec_portal2) & socsec_portal2  > 1 ~ 1,
      !is.na(socsec_portal2) & socsec_portal2 == 1 ~ 0.75,
      socsec_portal1 == 2 ~ 0.75,
      socsec_portal1 == 1 ~ 0.5,
      socsec_portal1 == 0 ~ 0
    ),
    # jobs portal
    #   - full: registration, search and application
    #   - partial: registration and search only
    jobs_portal = dplyr::case_when(
      !is.na(jobs_portal2) & jobs_portal2  > 1 ~ 1,
      !is.na(jobs_portal2) & jobs_portal2 == 1 ~ 0.75,
      jobs_portal1 == 2 ~ 0.75,
      jobs_portal1 == 1 ~ 0.5,
      jobs_portal1 == 0 ~ 0
    )
  ) |>
  # remove intermediate variables
  dplyr::select(
    -architecture1, -architecture2, -interoperability1, -interoperability2,
    -service_bus1, -service_bus2, -financial_mis1, -financial_mis2,
    -eprocurement1, -eprocurement2, -tax_portal1, -tax_portal2,
    -tax_efiling1, -tax_efiling2, -epayment1, -epayment2,
    -customs_portal1, -customs_portal2, -socsec_portal1, -socsec_portal2,
    -jobs_portal1, -jobs_portal2
  )

# generate output dataset
gtmi_out <- gtmi_proc |>
  # pivot back to long
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -ref_year),
    names_to = "int_var", values_to = "value"
  ) |>
  # match values to output variables
  dplyr::left_join(gtmi_vars_meta, by = "int_var") |>
  # calculate output values as sum of relevant intermediate variable values
  dplyr::summarise(
    value = sum(value),
    .by = c(cc_iso3c, ref_year, variable)
  )

# check all output codes are valid
check_codes(gtmi_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(gtmi_out, "data_out/gtmi_2022.csv")
