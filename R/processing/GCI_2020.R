
# load utility functions
source("R/utils/country_codes.R")
source("R/utils/write_standard_csv.R")

# read preprocessed dataset
# see ../preprocessing/GCI_2020_preprocess.R
gci_raw <- readr::read_csv("data_raw/GCI_2020/gci_2020.csv")

# drop overall GCI score
gci_proc <- gci_raw |>
  dplyr::filter(variable != "gci_overall")

# check all output codes are valid
check_codes(gci_proc$cc_iso3c, .stop = TRUE, .success = FALSE)

# write output dataset
write_standard_csv(gci_proc, "data_out/gci_2020.csv")
