# World Bank Open Data

Metadata | Value
--- | ---
Name | World Bank Open Data
Publication date | ongoing (data accessed 2024-06-06)
Reference date | 2023
Publisher | World Bank
Publisher URL | https://www.worldbank.org
Publication site | https://data.worldbank.org
Publication page | https://data.worldbank.org
Source file | `wb_wdi_2024.csv`
Source URL | https://data.worldbank.org (API)
Source format | CSV (.csv)
Copyright/licence | CC-BY-4.0
Processing script | `WB_WDI_2024.R`

## About the data

The World Bank Open Data portal (formerly the World Development Indicators) is
the World Bank's primary data repository for accessing global statistics
collated and produced by the World Bank. Data on GDP and population are
retrieved from the World Bank's Data API and stored in a CSV file in this
folder. These are used for contextual analysis.

## Extracted variables

6 variables are extracted

### Variable definition

Variable | Description
--- | ---
wb_gdp_ppp | GDP, PPP (current international dollars)
wb_gdp_usd | GDP (current US dollars)
wb_gdppc_ppp | GDP per capita, PPP (current international dollars)
wb_gdppc_usd | GDP per capita (current US dollars)
wb_govt_spending | General government final consumption expenditure (% of GDP)
wb_pop_total | Population, total

### Variable summary statistics

Variable | Countries | Year min | Year max | Value min | Value max
--- | ---: | ---: | ---: | ---: | ---:
wb_gdp_ppp | 199 | 2019 | 2022 | 61345526.536 | 31773060553367.3
wb_gdp_usd | 210 | 2018 | 2022 | 59065979.023 | 2.54397e+13
wb_gdppc_ppp | 199 | 2019 | 2022 | 917.503 | 146457.021
wb_gdppc_usd | 210 | 2020 | 2022 | 259.025 | 240862.182
wb_govt_spending | 176 | 2018 | 2022 | 2.36 | 70.435
wb_pop_total | 216 | 2022 | 2022 | 11312 | 1417173173

## Processing notes

