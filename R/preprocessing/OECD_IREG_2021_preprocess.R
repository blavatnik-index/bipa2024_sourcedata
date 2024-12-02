# download OECD iREG data

# load API callers
source("R/utils/oecd_api.R")

# iREG indicators dataset -------------------------------------------------

# get IREG composite indicators data
oecd_api_data(
  agency_identifier = "OECD.GOV.GIP",
  dataflow_identifier = "DSD_GOV_REG@DF_GOV_REG_2023",
  dataflow_version = "1.0",
  filter_expression = "A.......",
  startPeriod = 2014,
  out_file = "data_raw/OECD/OECD_IREG_2021/oecd_ireg_2021_indicators.csv"
)

# get IREG indicators metadata
oecd_api_meta(
  agency_identifier = "OECD.GOV.GIP",
  dataflow_identifier = "DSD_GOV_REG@DF_GOV_REG_2023",
  dataflow_version = "1.0",
  out_file = "data_raw/OECD/OECD_IREG_2021/oecd_ireg_2021_indicators_meta.xml"
)

# convert indicators metadata to CSV
oecd_xml_metadata(
  "data_raw/OECD/OECD_IREG_2021/oecd_ireg_2021_indicators_meta.xml",
  write = TRUE
)

# IREG survey dataset -----------------------------------------------------

# get IREG survey questions data
oecd_api_data(
  agency_identifier = "OECD.GOV.GIP",
  dataflow_identifier = "DSD_QDD_GOV_REG@DF_GOV_REG",
  dataflow_version = "1.0",
  filter_expression = "A....",
  out_file = "data_raw/OECD/OECD_IREG_2021/oecd_ireg_2021_survey.csv"
)

# get IREG survey questions metadata
oecd_api_meta(
  agency_identifier = "OECD.GOV.GIP",
  dataflow_identifier = "DSD_QDD_GOV_REG@DF_GOV_REG",
  dataflow_version = "1.0",
  out_file = "data_raw/OECD/OECD_IREG_2021/oecd_ireg_2021_survey_meta.xml"
)

# convert survey metadata from XML to CSV
oecd_xml_metadata(
  "data_raw/OECD/OECD_IREG_2021/oecd_ireg_2021_survey_meta.xml",
  write = TRUE
)
