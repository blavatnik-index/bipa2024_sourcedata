# Logistics Performance Index 2022 - pre-processing
# ==================================
# retrieve data from the World Bank API for the Logistics Performance Index

# load API callers
source("R/utils/wb_api.R")

# download LPI scores from World Bank API
lpi_raw <- wb_api_call(indicator = "LP.LPI.CUST.XQ", mrv = 1)

# write data to raw folder
readr::write_excel_csv(lpi_proc, "data_raw/LPI_2022/lpi_2022.csv")
