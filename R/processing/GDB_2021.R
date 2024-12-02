
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read dataset
gdb_raw <- readr::read_csv("data_raw/GDB_2021/gdb-2021-full-dataset.csv")

# process raw GDB data
gdb_proc <- gdb_raw |>
  # exclude secondary data from other sources
  dplyr::filter(indicator_type == "Primary" & hierarchy_level == 1 &
                  data_type == "response") |>
  dplyr::mutate(
    # set initial variable names
    base_variable = dplyr::case_when(
      variable_name == "G.GOVERNANCE.DPL" ~
        "gdb_governance_data_protection",
      variable_name == "G.GOVERNANCE.ODPOLICY" ~
        "gdb_governance_open_data",
      variable_name == "G.GOVERNANCE.DATASHARING" ~
        "gdb_governance_sharing",
      variable_name == "G.GOVERNANCE.DATAMANAGE" ~
        "gdb_governance_management",
      variable_name == "G.GOVERNANCE.ACCESSIBILITY" ~
        "gdb_governance_accessibility",
      variable_name == "C.CAPABILITIES.TRAIN" ~
        "gdb_capabilities_training",
      variable_name == "C.CAPABILITIES.ODINIT" ~
        "gdb_capabilities_initiatives",
      variable_name == "C.CAPABILITIES.GOVSUPPORT" ~
        "gdb_capabilities_reuse",
      variable_name == "G.COMPANY.BOT" ~
        "gdb_company_gov_ownership",
      variable_name == "A.COMPANY.BOT" ~
        "gdb_company_avl_ownership",
      variable_name == "A.COMPANY.REG" ~
        "gdb_company_avl_register",
      variable_name == "U.COMPANY.DUEDIL" ~
        "gdb_company_use_duedil",
      variable_name == "A.LAND.TENURE" ~
        "gdb_land_avl_tenure",
      variable_name == "A.LAND.ELU" ~
        "gdb_land_avl_landuse",
      variable_name == "U.LAND.GENDERINCLUSION" ~
        "gdb_land_use_gender",
      variable_name == "G.PI.POLFIN" ~
        "gdb_integrity_gov_polfin",
      variable_name == "A.PI.POLFIN" ~
        "gdb_integrity_avl_polfin",
      variable_name == "G.PI.IAD" ~
        "gdb_integrity_gov_assets",
      variable_name == "A.PI.IAD" ~
        "gdb_integrity_avl_assets",
      variable_name == "G.PI.LOBBY" ~
        "gdb_integrity_gov_lobbying",
      variable_name == "A.PI.LOBBY" ~
        "gdb_integrity_avl_lobbying",
      variable_name == "G.PI.PUBCON" ~
        "gdb_integrity_gov_consultation",
      variable_name == "A.PI.PUBCON" ~
        "gdb_integrity_avail_consultation",
      variable_name == "G.PI.RTI" ~
        "gdb_integrity_gov_rti",
      variable_name == "A.PI.RTI" ~
        "gdb_integrity_avl_rti",
      variable_name == "C.PI.INTEROP" ~
        "gdb_integrity_cap_interopability",
      variable_name == "U.PI.ACCOUNT" ~
        "gdb_integrity_use_accountability",
      variable_name == "G.PF.PUB-FINANCE" ~
        "gdb_pubfin_gov_pubfin",
      variable_name == "A.PF.BUDGETSPEND" ~
        "gdb_pubfin_avl_spending",
      variable_name == "A.PROCUREMENT.OC" ~
        "gdb_procurement_avl_opencontract",
      variable_name == "U.PROCUREMENT.ANALYTICS" ~
        "gdb_procurement_use_analytics",
      variable_name == "A.CLIMATE.EMI" ~
        "gdb_climate_avl_emissions",
      variable_name == "A.CLIMATE.BIO" ~
        "gdb_climate_avl_biodiversity",
      variable_name == "A.CLIMATE.VUL" ~
        "gdb_climate_avl_vulnerability",
      variable_name == "A.HEALTH.CRVS" ~
        "gdb_health_avl_vital_stats",
      variable_name == "A.HEALTH.RTC" ~
        "gdb_health_avl_rt_capacity",
      variable_name == "A.HEALTH.VAC" ~
        "gdb_health_avl_covid_vaccination"
    )
  ) |>
  dplyr::select(
    cc_iso3c = iso3,
    base_variable,
    score,
    wip, wib, wim
  ) |>
  tidyr::drop_na(base_variable) |>
  dplyr::mutate(
    # set country code
    cc_iso3c = dplyr::if_else(
      cc_iso3c == "XKX", "XKK", cc_iso3c
    ),
    # generate output variable name
    variable = dplyr::case_when(
      grepl("^gdb_governance", base_variable) ~ "gdb_governance",
      grepl("^gdb_capabilities", base_variable) ~ "gdb_capabilities",
      grepl("^gdb_company", base_variable) ~ "gdb_company",
      grepl("^gdb_land", base_variable) ~ "gdb_land",
      grepl("^gdb_integrity", base_variable) ~ "gdb_integrity",
      grepl("^gdb_pubfin", base_variable) ~ "gdb_pubfin",
      grepl("^gdb_procurement", base_variable) ~ "gdb_procurement",
      grepl("^gdb_climate", base_variable) ~ "gdb_climate",
      grepl("^gdb_health", base_variable) ~ "gdb_health"
    )
  )

# generate output dataset
gdb_out <- gdb_proc |>
  # merge weights
  dplyr::left_join(
    gdb_proc |>
      dplyr::distinct(base_variable, variable, wim) |>
      dplyr::mutate(new_w = wim/sum(wim), .by = variable) |>
      dplyr::select(base_variable, new_w),
    by = "base_variable"
  ) |>
  # calculate weighted sums for countries and variables
  dplyr::summarise(
    value = sum(new_w * score), .by = c(cc_iso3c, variable)
  ) |>
  dplyr::arrange(cc_iso3c, variable, value) |>
  dplyr::mutate(ref_year = 2021) |>
  dplyr::select(
    cc_iso3c, ref_year, variable, value
  )

# check all output codes are valid
check_codes(gdb_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(gdb_out, "data_out/gdb_2021.csv")

