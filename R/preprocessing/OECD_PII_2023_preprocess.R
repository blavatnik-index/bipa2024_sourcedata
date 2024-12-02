
# load API callers
source("R/utils/oecd_api.R")

# download PII data
oecd_api_data(
  agency_identifier = "OECD.GOV.PSI",
  dataflow_identifier = "DSD_PII@DF_PUBLIC_INTEGRITY",
  dataflow_version = "1.3",
  filter_expression = ".A..._T.",
  startPeriod = 2020,
  endPeriod = 2023,
  out_file = "data_raw/OECD/OECD_PII_2023/oecd-pii_2023.csv"
)

# download PII metadata
oecd_api_meta(
  agency_identifier = "OECD.GOV.PSI",
  dataflow_identifier = "DSD_PII@DF_PUBLIC_INTEGRITY",
  dataflow_version = "1.3",
  out_file = "data_raw/OECD/OECD_PII_2023/oecd-pii_2023_metadata.xml"
)

# convert PII metadata from XML to CSV
oecd_xml_metadata("data_raw/OECD/OECD_PII_2023/oecd-pii_2023_metadata.xml")
