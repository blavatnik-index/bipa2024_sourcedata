
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# load data ---------------------------------------------------------------

# ilo indicator tables
ilo_indicators <- c(
  "EMP_TEMP_SEX_ECO_NB_A", # employment by sex and economic activity
  "EMP_TEMP_SEX_INS_NB_A", # employment by sex and public/private
  "EMP_TEMP_SEX_OCU_INS_NB_A", # employment by sex, occupation and public/private
  "EMP_PUBL_SEX_EC2_NB_A", # public sector employment by ISIC sector
  "EMP_PUBL_SEX_OC2_NB_A", # public sector employment by ISCO occupation
  "EMP_PUBL_SEX_OCU_NB_A", # public sector employment by occupation level
  "EAR_4HPS_SEX_CUR_NB_A", # average hourly earnings in the public sector
  "PSE_TPSE_GOV_NB_A"	# public employment by SNA sub-sectors
)

# read and merge
ilo_raw <- purrr::map(
  .x = ilo_indicators,
  .f = ~readr::read_csv(
    file.path("data_raw", "ILOSTAT_2024", paste0(.x, ".csv")),
    col_types = readr::cols(.default = readr::col_character())
  )
) |>
  purrr::list_rbind()


# context data ------------------------------------------------------------

# calculate figures on size of government / public sector
ilo_sector_proc <- ilo_raw |>
  dplyr::filter(!grepl("^EAR", indicator)) |>
  dplyr::filter(is.na(sex) | sex == "SEX_T") |>
  dplyr::mutate(
    variable = dplyr::case_match(
      classif1,
      "GOV_LVL_TOTAL" ~       "pse_total_emp",
      "GOV_LVL_PSE" ~         "pse_total_pse",
      "GOV_LVL_GG" ~          "pse_govt_general",
      "GOV_LVL_GGCENTRAL" ~   "pse_govt_central",
      "EC2_ISIC3_L75" ~       "isic3s_public_admin",
      "EC2_ISIC3_TOTAL" ~     "isic3s_total",
      "ECO_ISIC3_L" ~         "isic3_public_admin",
      "ECO_ISIC3_TOTAL" ~     "isic3_total",
      "EC2_ISIC4_O84" ~       "isic4s_public_admin",
      "EC2_ISIC4_TOTAL" ~     "isic4s_total",
      "ECO_ISIC4_O" ~         "isic4_public_admin",
      "ECO_ISIC4_TOTAL" ~     "isic4_total",
      "INS_SECTOR_PUB" ~      "ind_public",
      "INS_SECTOR_TOTAL" ~    "ind_total"
    )
  ) |>
  dplyr::filter(!is.na(variable) & (is.na(obs_status) | obs_status != "U")) |>
  dplyr::select(ref_area, time, variable, obs_value) |>
  dplyr::mutate(across(c(time, obs_value), as.numeric)) |>
  dplyr::filter(obs_value != 0) |>
  tidyr::pivot_wider(names_from = variable, values_from = obs_value) |>
  dplyr::mutate(
    
    cc_iso3c = dplyr::if_else(ref_area == "KOS", "XKK", ref_area),
    
    # correct error in public sector employment totals
    pse_total_emp = dplyr::case_when(
      ref_area == "GBR" & time == 2021 ~ pse_total_emp * 1000,
      ref_area == "SVN" & time == 2018 ~ pse_total_emp * 1000,
      ref_area == "SVN" & time == 2019 ~ pse_total_emp * 1000,
      ref_area == "SVN" & time == 2021 ~ pse_total_emp * 1000,
      TRUE ~ pse_total_emp
    ),
    
    # industry estimate
    ## public sector as % of total employment
    rate_total_pse_ind = ind_public/ind_total,
    # isic4 estimates
    ## public sector as % of total employment
    rate_total_pse_isic4 = isic4s_total / isic4_total,
    ## public administration as % of total employment
    rate_total_pubadm_isic4_1 = isic4s_public_admin / isic4_total,
    rate_total_pubadm_isic4_2 = isic4_public_admin / isic4_total,
    ## public administration as % of public sector employment
    rate_pse_pubadm_isic4 = isic4s_public_admin / isic4s_total,
    # isic3 estimates
    ## public sector as % of total employment
    rate_total_pse_isic3 = isic3s_total / isic3_total,
    ## public administration as % of total employment
    rate_total_pubadm_isic3_1 = isic3s_public_admin / isic3_total,
    rate_total_pubadm_isic3_2 = isic3_public_admin / isic3_total,
    ## public administration as % of public sector employment
    rate_pse_pubadm_isic3 = isic3s_public_admin / isic3s_total,
    # government sector estimate
    ## public sector as % of total employment
    rate_total_pse_pse = pse_total_pse / pse_total_emp,
    ## central government as % of total employment
    rate_total_cengov_pse = pse_govt_central / pse_total_emp,
    ## central government as % of public sector employment
    rate_pse_cengov_pse = pse_govt_central / pse_total_pse
  )

ilo_sector_out <- ilo_sector_proc |>
  dplyr::mutate(

    # estimates - if no ISIC 4 use ISIC3, if no ISIC3, use government accounting
    # data, if no government accounting level, use industrial aggregates

    # public sector as % of total employment
    ilo_rate_total_pse = dplyr::case_when(
      !is.na(rate_total_pse_isic4) ~ rate_total_pse_isic4,
      !is.na(rate_total_pse_isic3) ~ rate_total_pse_isic3,
      !is.na(rate_total_pse_pse) ~ rate_total_pse_pse,
      !is.na(rate_total_pse_ind) ~ rate_total_pse_ind
    ),
    # public admin as % of total employment
    ilo_rate_total_pubad = dplyr::case_when(
      !is.na(rate_total_pubadm_isic4_1) ~ rate_total_pubadm_isic4_1,
      !is.na(rate_total_pubadm_isic4_2) ~ rate_total_pubadm_isic4_2,
      !is.na(rate_total_pubadm_isic3_1) ~ rate_total_pubadm_isic3_1,
      !is.na(rate_total_pubadm_isic3_2) ~ rate_total_pubadm_isic3_2,
    ),
    # public admin as % of public sector employment
    ilo_rate_pse_pubad = dplyr::case_when(
      !is.na(rate_pse_pubadm_isic4) ~ rate_pse_pubadm_isic4,
      !is.na(rate_pse_pubadm_isic3) ~ rate_pse_pubadm_isic3,
    ),
    ilo_rate_total_cengov = rate_total_cengov_pse,
    ilo_rate_pse_cengov = rate_pse_cengov_pse,
    ilo_size_pse = dplyr::case_when(
      !is.na(isic4s_total) ~ isic4s_total,
      !is.na(isic3s_total) ~ isic3s_total,
      !is.na(pse_total_pse) ~ pse_total_pse,
      !is.na(ind_public) ~ ind_public
    ),
    ilo_size_pubad = dplyr::case_when(
      !is.na(isic4s_public_admin) ~ isic4s_public_admin,
      !is.na(isic4_public_admin) ~ isic4_public_admin,
      !is.na(isic3s_public_admin) ~ isic3s_public_admin,
      !is.na(isic3_public_admin) ~ isic3_public_admin
    ),
    ilo_size_cengov = pse_govt_central
  ) |>
  dplyr::select(
    cc_iso3c, ref_year = time, starts_with("ilo_")
  ) |>
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -ref_year),
    names_to = "variable", values_to = "value"
  ) |>
  tidyr::drop_na(value) |>
  dplyr::filter(ref_year == max(ref_year), .by = c(cc_iso3c, variable)) |>
  dplyr::arrange(cc_iso3c, ref_year, variable)


# diversity metrics -------------------------------------------------------

# calculate figures on sex split in public sector/government
ilo_sex <- ilo_raw |>
  dplyr::filter(!grepl("^EAR", indicator)) |>
  # subset to only data on male/female employment
  dplyr::filter(sex == "SEX_M" | sex == "SEX_F") |>
  dplyr::mutate(
    variable = dplyr::case_when(
      classif1 == "EC2_ISIC3_L75" ~       "isic3s_public_admin",
      classif1 == "EC2_ISIC3_TOTAL" ~     "isic3s_total",
      classif1 == "ECO_ISIC3_L" ~         "isic3_public_admin",
      classif1 == "ECO_ISIC3_TOTAL" ~     "isic3_total",
      classif1 == "EC2_ISIC4_O84" ~       "isic4s_public_admin",
      classif1 == "EC2_ISIC4_TOTAL" ~     "isic4s_total",
      classif1 == "ECO_ISIC4_O" ~         "isic4_public_admin",
      classif1 == "ECO_ISIC4_TOTAL" ~     "isic4_total",
      classif1 == "INS_SECTOR_PUB" ~      "ind_public",
      classif1 == "INS_SECTOR_TOTAL" ~    "ind_total",
      classif1 == "ECO_AGGREGATE_PUB" ~   "agg_public",
      classif1 == "ECO_AGGREGATE_TOTAL" ~ "agg_total",
      classif1 == "OCU_SKILL_L3-4" &
        classif2 == "INS_SECTOR_PUB" ~    "high_skilled",
      classif1 == "OCU_ISCO08_1" ~        "isco08_mgrprof",
      classif1 == "OCU_ISCO08_2" ~        "isco08_mgrprof",
      classif1 == "OC2_ISCO08_11" ~       "isco08_seniormgrs",
      classif1 == "OCU_ISCO88_1" ~        "isco88_mgrprof",
      classif1 == "OCU_ISCO88_2" ~        "isco88_mgrprof",
      classif1 == "OC2_ISCO88_11" ~       "isco88_seniormgrs",
      classif1 == "OC2_ISCO88_12" ~       "isco88_seniormgrs"
    ),
    across(c(time, obs_value), as.numeric)
  ) |>
  # generate total values for all categories
  dplyr::filter(!is.na(variable) & (is.na(obs_status) | obs_status != "U")) |>
  dplyr::select(ref_area, time, sex, variable, obs_value) |>
  dplyr::arrange(ref_area, time, variable, sex) |>
  dplyr::summarise(
    obs_value = sum(obs_value, na.rm = TRUE), .by = c(ref_area, time, sex, variable)
  ) |>
  # only get data where there are two values per country (i.e. both a male and
  # female total available)
  dplyr::add_count(ref_area, time, variable) |>
  dplyr::filter(n == 2) |>
  # calculate proportions
  dplyr::mutate(
    value = obs_value / sum(obs_value), .by = c(ref_area, time, variable)
  ) |>
  # limit to percent female
  dplyr::filter(sex == "SEX_F") |>
  dplyr::select(ref_area, time, variable, value) |>
  # pivot dataset and calculate output variables
  tidyr::pivot_wider(names_from = variable, values_from = value) |>
  dplyr::mutate(
    # convert country codes
    cc_iso3c = dplyr::if_else(ref_area == "KOS", "XKK", ref_area),
    # set overall public sector rate, use industry data if available,
    # otherwise use economic sector aggregate
    ilo_pse_female = dplyr::case_when(
      !is.na(ind_public) ~ ind_public,
      !is.na(agg_public) ~ agg_public,
      TRUE ~ NA_real_
    ),
    # set public administration rate, use ISIC4 if available, otherwise use
    # ISIC3
    ilo_pubad_female = dplyr::case_when(
      !is.na(isic4s_public_admin) ~ isic4s_public_admin,
      !is.na(isic4_public_admin)  ~ isic4_public_admin,
      !is.na(isic3s_public_admin) ~ isic3s_public_admin,
      !is.na(isic3_public_admin)  ~ isic3_public_admin,
      TRUE ~ NA_real_
    ),
    # set public sector management rate, use ISCO08 if available, otherwise
    # use ISCO88, if ISCO88 not available use skill level as proxy
    ilo_ps_mgrpro_female = dplyr::case_when(
      !is.na(isco08_mgrprof) ~ isco08_mgrprof,
      !is.na(isco88_mgrprof) ~ isco88_mgrprof,
      !is.na(high_skilled) ~ high_skilled,
      TRUE ~ NA_real_
    ),
    # set public sector senior management rate, use ISCO08 if available,
    # otherwise use ISOC88
    ilo_ps_snrmgr_female = dplyr::case_when(
      !is.na(isco08_seniormgrs) ~ isco08_seniormgrs,
      !is.na(isco88_seniormgrs) ~ isco88_seniormgrs,
      TRUE ~ NA_real_
    )
  ) |>
  dplyr::select(cc_iso3c, ref_year = time, starts_with("ilo")) |>
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -ref_year),
    names_to = "variable",
    values_to = "value"
  ) |>
  tidyr::drop_na(value) |>
  dplyr::filter(
    ref_year == max(ref_year),
    .by = c(cc_iso3c, variable)
  )

# calculate public sector pay ratio (female hourly pay / male hourly pay)
ilo_paygap <- ilo_raw |>
  dplyr::filter(grepl("^EAR", indicator)) |>
  # subset to male & female values
  dplyr::filter(
    (sex == "SEX_M" | sex == "SEX_F") &
      (is.na(classif1) | classif1 == "CUR_TYPE_LCU") &
      (is.na(obs_status) | obs_status != "U")
  ) |>
  # limit to only observations where there are two values per country/year
  dplyr::add_count(ref_area, time) |>
  dplyr::filter(n == 2) |>
  # convert values to numeric, invert values for males
  dplyr::mutate(
    across(c(time, obs_value), as.numeric),
    value = dplyr::if_else(sex == "SEX_M", 1/obs_value, obs_value)
  ) |>
  # calculate pay ratio as product of female pay and inverted male pay
  dplyr::summarise(
    value = prod(value), .by = c(ref_area, time)
  ) |>
  # subset to latest data by country
  dplyr::filter(
    time == max(time), .by = c(ref_area)
  ) |>
  dplyr::mutate(
    variable = "ilo_ps_payratio"
  ) |>
  dplyr::select(
    cc_iso3c = ref_area,
    ref_year = time,
    variable,
    value
  )

# output ------------------------------------------------------------------

# output for metrics
ilo_out <- dplyr::bind_rows(
  ilo_sex,
  ilo_paygap
)

# check all output codes are valid
check_codes(ilo_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write metrics file
write_standard_csv(ilo_out, "data_out/ilostat_2024.csv")

# check all output codes are valid
check_codes(ilo_sector_out$cc_iso3c, .stop = TRUE, .success = FALSE)

# write contextual file
write_standard_csv(ilo_sector_out, "data_context/ilostat_2024.csv")
