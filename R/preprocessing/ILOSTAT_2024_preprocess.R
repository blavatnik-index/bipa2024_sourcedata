# ILO statistics download
# =========================
# function and calls to retrieve data from the ILO bulk download facility

# download files ----------------------------------------------------------

# load ILO API caller
source("R/utils/ilo_api.R")

# indicators to download
imf_indicators <- c(
  "EMP_TEMP_SEX_ECO_NB_A", # employment by sex and economic activity
  "EMP_TEMP_SEX_INS_NB_A", # employment by sex and public/private
  "EMP_TEMP_SEX_OCU_INS_NB_A", # employment by sex, occupation and public/private
  "EMP_PUBL_SEX_EC2_NB_A", # public sector employment by ISIC sector
  "EMP_PUBL_SEX_OC2_NB_A", # public sector employment by ISCO occupation
  "EMP_PUBL_SEX_OCU_NB_A", # public sector employment by occupation level
  "EAR_HUBL_SEX_NB_A", # mean nominal hourly earnings in the public sector
  "EAR_4HPS_SEX_CUR_NB_A", # average hourly earnings in the public sector
  "PSE_TPSE_GOV_NB_A"	# public employment by SNA sub-sectors
)

# download indicators
purrr::walk(
  .x = imf_indicators,
  .f = ~ilo_api_download(indicator = .x)
)

# dictionaries to download
imf_dics <- c(
  "ref_area",
  "source",
  "indicator",
  "sex",
  "classif1",
  "note_indicator",
  "note_source",
  "obs_status"
)

# download dictionaries
purrr::walk(
  .x = imf_dics,
  .f = ~ilo_dic_download(dictionary = .x)
)
