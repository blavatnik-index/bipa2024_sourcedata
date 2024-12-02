
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read ODIN data, exclude notes rows
odin_raw <- readr::read_csv("data_raw/ODIN_2022/ODIN_03222024.csv",
                            n_max = 4485, na = c("", "NA", "-"))

# process ODIN data
odin_proc <- odin_raw |>
  janitor::clean_names() |>
  # remove superfluous columns
  dplyr::select(-region, -region_code, -country) |>
  # pivot dataset to long
  tidyr::pivot_longer(
    cols = c(-year, -country_code, -data_categories),
    names_to = "odin_variable",
    values_to = "value"
  ) |>
  dplyr::mutate(
    # set category group
    odin_group = dplyr::case_when(
      data_categories == "Population & vital statistics" ~ "social",
      data_categories == "Education facilities" ~ "social",
      data_categories == "Education outcomes" ~ "social",
      data_categories == "Health facilities" ~ "social",
      data_categories == "Health outcomes" ~ "social",
      data_categories == "Reproductive health" ~ "social",
      data_categories == "Food security & nutrition" ~ "social",
      data_categories == "Gender statistics" ~ "social",
      data_categories == "Crime & justice" ~ "social",
      data_categories == "Poverty & income" ~ "social",
      data_categories == "National accounts" ~ "economic",
      data_categories == "Labor" ~ "economic",
      data_categories == "Price indexes" ~ "economic",
      data_categories == "Government finance" ~ "economic",
      data_categories == "Money & banking" ~ "economic",
      data_categories == "International trade" ~ "economic",
      data_categories == "Balance of payments" ~ "economic",
      data_categories == "Agriculture and land use" ~ "environmental",
      data_categories == "Resource use" ~ "environmental",
      data_categories == "Energy" ~ "environmental",
      data_categories == "Pollution" ~ "environmental",
      data_categories == "Built environment" ~ "environmental",
      data_categories == "All Categories" ~ NA_character_
    ),
    # set measure group
    odin_measure = dplyr::case_when(
      odin_variable == "indicator_coverage_and_disaggregation" ~ "coverage",
      odin_variable == "data_available_last_5_years" ~ "coverage",
      odin_variable == "data_available_last_10_years" ~ "coverage",
      odin_variable == "first_administrative_level" ~ "coverage",
      odin_variable == "second_administrative_level" ~ "coverage",
      odin_variable == "machine_readable" ~ "openness",
      odin_variable == "non_proprietary" ~ "openness",
      odin_variable == "download_options" ~ "openness",
      odin_variable == "metadata_available" ~ "openness",
      odin_variable == "terms_of_use" ~ "openness",
      odin_variable == "overall_score" ~ NA_character_
    )
  ) |>
  # drop overall figures
  tidyr::drop_na(odin_group, odin_measure) |>
  # calculate scores for category and measure groups
  dplyr::summarise(
    value = sum(value, na.rm = TRUE),
    .by = c(country_code, year, odin_group, odin_measure)
  ) |>
  dplyr::mutate(
    # generate variable name
    variable = paste("odin", odin_group, odin_measure, sep = "_"),
    # replace Kosovo code
    cc_iso3c = dplyr::if_else(country_code == "XKX", "XKK", country_code)
  ) |>
  dplyr::select(
    cc_iso3c, ref_year = year, variable, value
  )


# check all output codes are valid
check_codes(odin_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(odin_proc, "data_out/odin_2022.csv")
