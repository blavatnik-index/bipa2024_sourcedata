
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read OBS dataset
obs_raw <- readxl::read_excel("data_raw/OBS_2023/ibp_data_2023_statfile.xlsx")

# define OBS output groups
obs_groups <- list(
  "obs_documents" = c(
    # pre-budget report
    "q54", "q55", "q56", "q57", "q58", "t3pbs",
    # budget proposal =
    "q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10", "q11",
    "q12", "q13", "q14", "q15", "q16", "q17", "q18", "q19", "q20", "q21",
    "q22", "q23", "q24", "q25", "q26", "q27", "q28", "q29", "q30", "q31",
    "q32", "q33", "q34", "q35", "q36", "q37", "q38", "q39", "q40", "q41",
    "q42", "q43", "q44", "q45", "q46", "q47", "q48", "q49", "q50", "q51",
    "q52", "q53", "t3ebp",
    # enacted budget
    "q59", "q60", "q61", "q62", "q63", "t3eb",
    # in-year reports
    "q68", "q69", "q70", "q71", "q72", "q73", "q74", "q75", "t3iyr",
    # mid-year reports
    "q76", "q77", "q78", "q79", "q80", "q81", "q82", "q83", "t3myr",
    # year-end reports
    "q84", "q85", "q86", "q87", "q88", "q89", "q90", "q91", "q92", "q93",
    "q94", "q95", "q96", "t3yer"
  ),
  "obs_consultation" = c(
    # public participation
    "q125", "q126", "q127", "q128", "q129", "q130", "q131", "q132", "q133",
    "q134", "q135", "q136", "q137", "q138", "q139", "q140", "q141", "q142",
    # citizens' budget document
    "q64", "q65", "q66", "q67"
  ),
  "obs_oversight"  = c(
    # legislative oversight
    "q107", "q108", "q109", "q110", "q111", "q112", "q113", "q114", "q115",
    "q116", "q117", "q118",
    # SAI oversight
    "q119", "q120", "q121", "q122", "q123", "q124",
    # audit report
    "q97", "q98", "q99", "q100", "q101", "q102", "t3ar",
    # IFIs
    "q103", "q104", "q105", "q106"
  )
)

# convert groups to data frame
obs_groups_df <- tibble::tibble(
  variable = names(obs_groups),
  question = obs_groups
) |>
  tidyr::unnest_longer(question)

# process OBS data
obs_proc <- obs_raw |>
  # subset columns of interest
  dplyr::select(
    cc_iso3c = ISO,
    ref_year = year,
    matches("q\\d+$|t3.*")
  ) |>
  # pivot and match groups
  tidyr::pivot_longer(
    cols = c(-cc_iso3c, -ref_year), names_to = "question", values_to = "value"
  ) |>
  dplyr::mutate(value = value/100) |>
  dplyr::left_join(
    obs_groups_df, by = "question"
  ) |>
  # calculate group summarise for each
  dplyr::summarise(
    value = sum(value, na.rm = TRUE),
    .by = c(cc_iso3c, ref_year, variable)
  )

# check all output codes are valid
check_codes(obs_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(obs_proc, "data_out/obs_2023.csv")
