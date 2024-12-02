# WB WDI statistics download
# ============================
# retrieve data from the World Bank API for the Worldwide Development Indicators

# load API caller
source("R/utils/wb_api.R")

# indicators to download
wb_indicators <- c(
  "NY.GDP.MKTP.CD", # GDP, current US $
  "NY.GDP.MKTP.PP.CD", # GDP, PPP, current international $
  "NY.GDP.PCAP.CD", # GDP per capita, current US $
  "NY.GDP.PCAP.PP.CD", # GDP per capita, PPP, current international $
  "NE.CON.GOVT.ZS", # General government expenditure, % of GDP
  "SP.POP.TOTL" # total population
)

# call API
wb_api_raw <- purrr::map(
  .x = wb_indicators,
  .f = ~wb_api_call(indicator = .x, mrv = 5)
)

# simplify list into dataset
wb_api_out <- wb_api_raw |>
  purrr::list_rbind()

readr::write_excel_csv(wb_api_out, "data_raw/WB_2024/wb_wdi_2024.csv")
