
# load UN API caller
source("R/utils/unsdg_api.R")

# download SFM dataset
unsdg_api("SG_DSR_LGRGSR", out_file = "data_raw/UNSFM_2023/un_sfm_2023.csv")
