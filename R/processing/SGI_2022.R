
# load utility functions
source("R/utils/write_standard_csv.R")

# read SGI dataset
sgi_raw <- tidyxl::xlsx_cells(
  "data_raw/SGI_2022/SGI2022_Scores.xlsx",
  sheets = "SGI 2022 Scores"
)

# processes raw data
sgi_proc <- sgi_raw |>
  dplyr::filter(row > 1) |>
  dplyr::mutate(
    # set output variables
    variable = dplyr::case_match(
      col,
      147 ~ "sgi_access_gov_info",
      167 ~ "sgi_strategic_planning",
      168 ~ "sgi_expert_advice",
      170 ~ "sgi_go_expertise",
      171 ~ "sgi_line_ministries",
      172 ~ "sgi_cabinet_committees",
      173 ~ "sgi_official_coordination",
      174 ~ "sgi_informal_coordination",
      # 175 ~ "sgi_digital_coordination",
      177 ~ "sgi_ria_application",
      178 ~ "sgi_ria_quality",
      179 ~ "sgi_ria_sustainability",
      180 ~ "sgi_evidence_based",
      182 ~ "sgi_civic_consultation",
      183 ~ "sgi_coherent_comms",
      186 ~ "sgi_achieve_objectives",
      187 ~ "sgi_implement_policy",
      188 ~ "sgi_monitor_ministries",
      189 ~ "sgi_monitor_agencies",
      190 ~ "sgi_subnational_funding",
      191 ~ "sgi_subnational_discretion",
      192 ~ "sgi_subnational_standards",
      193 ~ "sgi_regulatory_enforcement",
      195 ~ "sgi_domestic_adaptation",
      196 ~ "sgi_international_collaboration",
      198 ~ "sgi_self_monitoring",
      199 ~ "sgi_institutional_reform"
    ),
    # set country
    country = dplyr::if_else(col == 1, character, NA_character_)
  ) |>
  # fill country across columns
  dplyr::arrange(row, col) |>
  tidyr::fill(country) |>
  tidyr::drop_na(variable) |>
  # convert country names to codes, set reference year
  dplyr::mutate(
    cc_iso3c = countrycode::countrycode(
      country,
      origin = "country.name.en",
      destination = "iso3c"
    ),
    ref_year = 2022
  ) |>
  dplyr::select(cc_iso3c, ref_year, variable, value = numeric)

# write output dataset
write_standard_csv(sgi_proc, "data_out/sgi_2022.csv")
