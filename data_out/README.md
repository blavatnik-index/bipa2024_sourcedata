Blavatnik Index of Public Administration 2024: Source data processing

# Output data

This folder contains the output of the source data processing for the
Blavatnik Index of Public Administration 2024. For each data source a
standardised CSV file has been exported with four columns:

- `cc_iso3c`: the 3-character country code derived from the ISO 3166-1 standard
- `ref_year`: the 4-digit reference year
- `variable`: the variable name of the data point
- `value`: the numeric value of the data point

In many cases the data points are directly transposed from the source data,
however for some sources there has been re-processing of the data. Please refer
to the markdown documentation file (`.md`) in the relevant [`data_raw`] folder
and/or the processing scripts in the [`R/processing`](../R/processing/) folder
for full details.

CSV file | Documentation file | Processing file
--- | --- | ---
`bti_2024.csv` | [`BTI_2024.md`](../data_raw/BTI_2024/BTI_2024.md) | [`BTI_2024.R`](../R/processing/BTI_2024.R)
`db_2020.csv` | [`DB_2020.md`](../data_raw/DB_2020/DB_2020.md) | [`DB_2020.R`](../R/processing/DB_2020.R)
`egbr_2022.csv` | [`EGBR_2022.md`](../data_raw/EGBR_2022/EGBR_2022.md) | [`EGBR_2022.R`](../R/processing/EGBR_2022.R)
`eige_2023.csv` | [`EIGE_2023.md`](../data_raw/EIGE_2023/EIGE_2023.md) | [`EIGE_2023.R`](../R/processing/EIGE_2023.R)
`gcb_2021.csv` | [`GCB_2021.md`](../data_raw/GCB_2021/GCB_2021.md) | [`GCB_2021.R`](../R/processing/GCB_2021.R)
`gci_2020.csv` | [`GCI_2020.md`](../data_raw/GCI_2020/GCI_2020.md) | [`GCI_2020.R`](../R/processing/GCI_2020.R)
`gdb_2021.csv` | [`GDB_2021.md`](../data_raw/GDB_2021/GDB_2021.md) | [`GDB_2021.R`](../R/processing/GDB_2021.R)
`gtmi_2022.csv` | [`GTMI_2022.md`](../data_raw/GTMI_2022/GTMI_2022.md) | [`GTMI_2022.R`](../R/processing/GTMI_2022.R)
`ilostat_2024.csv` | [`ILOSTAT_2024.md`](../data_raw/ILOSTAT_2024/ILOSTAT_2024.md) | [`ILOSTAT_2024.R`](../R/processing/ILOSTAT_2024.R)
`isora_2021.csv` | [`ISORA_2021.md`](../data_raw/ISORA_2021/ISORA_2021.md) | [`ISORA_2021.R`](../R/processing/ISORA_2021.R)
`lpi_2022.csv` | [`LPI_2022.md`](../data_raw/LPI_2022/LPI_2022.md) | [`LPI_2022.R`](../R/processing/LPI_2022.R)
`obs_2021.csv` | [`OBS_2021.md`](../data_raw/OBS_2021/OBS_2021.md) | [`OBS_2021.R`](../R/processing/OBS_2021.R)
`odin_2022.csv` | [`ODIN_2022.md`](../data_raw/ODIN_2022/ODIN_2022.md) | [`ODIN_2022.R`](../R/processing/ODIN_2022.R)
`oecd_dgi_2023.csv` | [`OECD_DGI_2023.md`](../data_raw/OECD_DGI_2023/OECD_DGI_2023.md) | [`OECD_DGI_2023.R`](../R/processing/OECD_DGI_2023.R)
`oecd_ireg_2021.csv` | [`OECD_IREG_2021.md`](../data_raw/OECD_IREG_2021/OECD_IREG_2021.md) | [`OECD_IREG_2021.R`](../R/processing/OECD_IREG_2021.R)
`oecd_ourdata_2023.csv` | [`OECD_OURDATA_2022.md`](../data_raw/OECD_OURDATA_2022/OECD_OURDATA_2022.md) | [`OECD_OURDATA_2022.R`](../R/processing/OECD_OURDATA_2022.R)
`oecd_pii_2023.csv` | [`OECD_PII_2023.md`](../data_raw/OECD_PII_2023/OECD_PII_2023.md) | [`OECD_PII_2023.R`](../R/processing/OECD_PII_2023.R)
`oecd_pslc_2020.csv` | [`OECD_PSLC_2020.md`](../data_raw/OECD_PSLC_2020/OECD_PSLC_2020.md) | [`OECD_PSLC_2020.R`](../R/processing/OECD_PSLC_2020.R)
`oecd_pslc_2022.csv` | [`OECD_PSLC_2022.md`](../data_raw/OECD_PSLC_2022/OECD_PSLC_2022.md) | [`OECD_PSLC_2022.R`](../R/processing/OECD_PSLC_2022.R)
`paris21_2020.csv` | [`PARIS21_2020.md`](../data_raw/PARIS21_2020/PARIS21_2020.md) | [`PARIS21_2020.R`](../R/processing/PARIS21_2020.R)
`qog_2020.csv` | [`QOG_2020.md`](../data_raw/QOG_2020/QOG_2020.md) | [`QOG_2020.R`](../R/processing/QOG_2020.R)
`roli_2023.csv` | [`ROLI_2023.md`](../data_raw/ROLI_2023/ROLI_2023.md) | [`ROLI_2023.R`](../R/processing/ROLI_2023.R)
`sfm_2023.csv` | [`SFM_2023.md`](../data_raw/SFM_2023/SFM_2023.md) | [`SFM_2023.R`](../R/processing/SFM_2023.R)
`sgi_2022.csv` | [`SGI_2022.md`](../data_raw/SGI_2022/SGI_2022.md) | [`SGI_2022.R`](../R/processing/SGI_2022.R)
`vdem_2023.csv` | [`VDEM_2023.md`](../data_raw/VDEM_2023/VDEM_2023/VDEM_2023.md) | [`VDEM_2023.R`](../R/processing/VDEM_2023.R)
































