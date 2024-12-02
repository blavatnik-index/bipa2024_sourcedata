
# processing requires a pre-processed dataset
# see ../preprocessing/OECD_DGI_2023_preprocess.R

# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read raw dataset
dgi_raw <- readr::read_csv("data_raw/OECD_DGI_2023/oecd_dgi_2023.csv")

# exclude overall score and generate variable name
dgi_proc <- dgi_raw |>
  dplyr::filter(variable != "composite_index" & variable != "composite_rank") |>
  dplyr::mutate(variable = paste0("dgi_", variable))

# check all output codes are valid
check_codes(dgi_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(dgi_proc, "data_out/oecd_dgi_2023.csv")
