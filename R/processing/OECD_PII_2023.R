
# processing requires a pre-processed dataset
# see ../preprocessing/OECD_PII_2023_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read PII dataset
pii_raw <- readr::read_csv(
  "data_raw/OECD_PII_2023/oecd-pii_2023.csv"
)

# process PII data
pii_proc <- pii_raw |>
  janitor::clean_names() |>
  # keep only measures of interest
  dplyr::filter(
    measure %in% c(
      # strategic framework
      "PII_131", "PII_132", "PII_133", "PII_134", "PII_135", "PII_136",
      "PII_137", "PII_138",
      # internal control
      "PII_3101", "PII_3102", "PII_3103", "PII_3104", "PII_3105", "PII_3106",
      "PII_3107", "PII_3108", "PII_3109", "PII_31010", "PII_31011",
      # accountability
      "PII_3131", "PII_3132", "PII_3133", "PII_3134", "PII_3135", "PII_3136",
      "PII_3138", "PII_3139", "PII_31315"
    )
  ) |>
  dplyr::mutate(
    # set overall variables
    variable = dplyr::case_match(
      measure,
      # integrity framework
      "PII_131"	~ "integrity_framework",       # coverage of the framework
      "PII_132"	~ "integrity_framework",       # framework based on evidence
      "PII_133"	~ "integrity_framework",       # minimum content of framework
      "PII_134"	~ "integrity_framework",       # consultation on framework
      "PII_135"	~ "integrity_framework",       # framework reporting mechanisms
      "PII_136"	~ "integrity_framework",       # implementation of the framework
      "PII_137"	~ "integrity_framework",       # financial resources for framework
      "PII_138"	~ "integrity_framework",       # evaluation of integrity frameworks
      # internal control
      "PII_3101" ~	"control_regulations",     # internal control rules/regulations
      "PII_3102" ~	"control_regulations",     # internal audit rules/regulations
      "PII_3103" ~	"control_regulations",     # risk management rules/regulations
      "PII_3104" ~	"control_oversight",       # central functions for IC/IA
      "PII_3105" ~	"control_oversight",       # central reporting of IC/IA
      "PII_3106" ~	"control_practices",       # IA and risk-based practices
      "PII_3107" ~	"control_practices",       # risk management in budget practices
      "PII_3108" ~	"internal_audit",          # organisations covered by IA
      "PII_3109" ~	"internal_audit",          # organisations audited by IA
      "PII_31010" ~	"internal_audit",          # adoption/acceptance of IA recs
      "PII_31011" ~	"internal_audit",          # implementation of IA recs
      # accountability
      "PII_3131" ~	"openness_regulations",    # regulations for open government
      "PII_3132" ~	"lobbying_regulations",    # regulations on lobbyist activity
      "PII_3133" ~	"openness_functions",      # functions for open government
      "PII_3134" ~	"open_decisions",          # openness of meetings & decisions
      "PII_3135" ~	"consultation_practices",  # public consultation practices
      "PII_3136" ~	"conflict_of_interest",    # conflict of interest practices
      "PII_3138" ~	"lobbying_transparency",  # transparency of lobbyist activity
      "PII_3139" ~	"proactive_disclosures",   # proactive data disclosure
      "PII_31315" ~	"officials_postemployment" # post-employment monitoring
    )
  ) |>
  # select percentage scores
  dplyr::filter(unit_measure == "PT_SCR_POS_MAX") |>
  # convert character values to numeric
  dplyr::mutate(
    value = dplyr::case_when(
      obs_status == "V" ~ NA_character_,
      obs_value == "Not tracking" ~ "0",
      obs_value == "Not available" ~ "0",
      TRUE ~ obs_value
    ),
    value = as.numeric(value)
  ) |>
  dplyr::select(ref_area, measure, time_period, variable, value) |>
  # carry forward scores from previous years
  dplyr::arrange(ref_area, measure, time_period) |>
  dplyr::group_by(ref_area, measure) |>
  tidyr::fill(value) |>
  dplyr::ungroup() |>
  # select latest time period
  dplyr::filter(time_period == max(time_period), .by = c(ref_area, measure)) |>
  # coerce scores to 0/1
  dplyr::mutate(
    value = value / 100,
    na_value = is.na(value)
  ) |>
  # calculate variable scores as sum of component metrics
  dplyr::summarise(
    value = sum(value, na.rm = TRUE),
    na_values = sum(na_value),
    ref_year = max(time_period),
    .by = c(ref_area, variable)
  ) |>
  dplyr::mutate(
    # drop variables with completely missing values
    value = dplyr::case_when(
      variable == "integrity_framework" & na_values == 8 ~ NA_real_,
      variable == "control_regulations" & na_values == 3 ~ NA_real_,
      variable == "control_oversight"   & na_values == 2 ~ NA_real_,
      variable == "control_practices"   & na_values == 2 ~ NA_real_,
      variable == "internal_audit"      & na_values == 4 ~ NA_real_,
      variable %in% c("openness_regulations", "lobbying_regulations",
                      "openness_functions", "open_decisions",
                      "consultation_practices", "conflict_of_interest",
                      "lobbying_transparency", "proactive_disclosures",
                      "officials_postemployment") & na_values == 1 ~ NA_real_,
      TRUE ~ value
    ),
    # generate variable names
    variable = paste("pii", variable, sep = "_")
  ) |>
  tidyr::drop_na(value) |>
  dplyr::select(cc_iso3c = ref_area, ref_year, variable, value)

# check all output codes are valid
check_codes(pii_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(pii_proc, "data_out/oecd_pii_2023.csv")
