Blavatnik Index of Public Administration 2024: Source data processing

# Raw data

The sub-folders within this folder contain the raw input data for the
Blavatnik Index of Public Administration 2024.

Each folder contains the raw data, supporting methodology documentation and
a README file providing metadata about the data and processing notes.

In the majority of cases the raw data is provided as some form of standard
data file, a CSV file, an Excel spreadsheet or a statistical data file
(e.g. a .dta, .rds or .sav format file). These are processed by associated
scripts in the [`R/processing`](../R/processing/) folder to produce
standardised outputs which are saved in the [`data_out`](../data_out/) folder.

In some cases the data is only available via a web API service or in a PDF file,
in which case this data has been downloaded or extracted via the scripts in the
[`R/preprocessing`](../R/preprocessing/) folder and then saved as a CSV in the
relevant sub-folders here for access by the processing scripts.

## Sources

Folder | Source | Publisher
--- | --- | ---
[`BTI_2024`](BTI_2024) | Bertelsmann Transformation Index | Bertelsmann Stiftung
[`DB_2020`](DB_2020) | Doing Business Report | World Bank
[`EGBR_2023`](EGBR_2023) | eGovernment Benchmark Report | European Commission
[`EGIE_2023`](EGIE_2023) | Gender Statistics Database | European Institute for Gender Equality
[`GCB`](GCB) | Global Corruption Barometer | Transparency International
[`GCI_2020`](GCI_2020) | Global Cybersecurity Index | International Telecommunications Union
[`GDB_2021`](GDB_2021) | Global Data Barometer | D4D.net and ILDA
[`GTMI_2022`](GTMI_2022) | GovTech Maturity Index | World Bank
[`ILOSTAT_2024`](ILOSTAT_2024) | ILOSTAT | International Labor Organization
[`ISORA_2021`](ISORA_2021) | International Survey of Revenue Administration | CIAT, IMF, IOTA and OECD
[`JURI_2018`](JURI_2018) | JuriGlobe | University of Ottawa
[`LPI_2022`](LPI_2022) | Logistics Performance Index | World Bank
[`OBS_2021`](OBS_2021) | Open Budget Survey | International Budget Partnership
[`ODIN_2022`](ODIN_2022) | Open Data Inventory | Open Data Watch
[`OECD/OECD_IREG_2021`](OECD/OECD_IREG_2021) | Indicators of Regulatory Governance | OECD
[`OECD/OECD_OURDATA_2023`](OECD/OECD_OURDATA_2023) | OUR Data Index | OECD
[`OECD/OECD_PII_2023`](OECD/OECD_PII_2023) | Public Integrity Indicators | OECD
[`OECD/OECD_PSLC_2020`](OECD/OECD_PSLC_2020) | Public Service Leadership and Capability Survey | OECD
[`OECD/OECD_PSLC_2022`](OECD/OECD_PSLC_2022) | Public Service Leadership and Capability Survey | OECD
[`PARIS21_2020`](PARIS21_2020) | PARIS21 Statistical Capability Monitor | PARIS21/OECD
[`QOG_2020`](QOG_2020) | Quality of Government Expert Survey | Quality of Government Institute, University of Gothenburg
[`ROLI_2023`](ROLI_2023) | Rule of Law Index | World Justice Project
[`SFM_2023`](SFM_2023) | Sendai Framework for Action Monitoring | United Nations
[`SGI_2022`](SGI_2022) | Sustainable Governance Indicators | Bertelsmann Stiftung
[`VDEM_2023`](VDEM_2023) | Varieties of Democracy Dataset | VDEM Institute, University of Gothenburg
[`WB_CC_2023`](WB_CC_2023) | World Bank Income Classifications | World Bank
[`WB_WDI_2024`](WB_WDI_2024) | World Development Indicators | World Bank

Please see the markdown documentation file (`.md` files) in each folder for
details of the data processing.