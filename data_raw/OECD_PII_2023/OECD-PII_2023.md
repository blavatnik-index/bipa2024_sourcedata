# OECD Public Integrity Indicators

Metadata | Value
--- | ---
Name | Public Integrity Indicators
Publication date | ongoing (data in repository as at 2024-06-11)
Reference date | 2022-2023
Publisher | OECD
Publisher URL | https://www.oecd.org/
Publication site | https://oecd-public-integrity-indicators.org
Publication page | https://oecd-public-integrity-indicators.org
Source file | `oecd-pii_2023.csv`
Source URL | https://data-explorer.oecd.org/vis?fs[0]=Topic%2C0%7CPublic%20governance%23GOV%23&pg=20&fc=Topic&bp=true&snb=28&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_PII%40DF_PUBLIC_INTEGRITY&df[ag]=OECD.GOV.PSI&df[vs]=1.3&dq=.A..._T.&pd=2020%2C2023&to[TIME_PERIOD]=false
Source format | CSV (.csv)
Copyright/licence | Re-use permitted for any purpose, https://www.oecd.org/en/about/terms-conditions.html
Pre-processing script | `OECD_PII_2023_preprocess.R`
Processing script | `OECD_PII_2023.R`

## About the data

The OECD Public Integrity Indicators are a dataset of measures relating to
anti-corruption and public integrity strategies, policies and practices in
OECD member and non-member countries.

## Extracted variables

14 variables are extracted

### Variable definition

Variable | Description
--- | ---
pii_consultation_practices | Practices for public consultation
pii_proactive_disclosures | Proactive disclosure of data and information
pii_open_decisions | Openness of meetings and decisions
pii_openness_functions | Supporting functions for open government
pii_openness_regulations | Regulations for open government
pii_lobbbying_transparency | Transparency of lobbyist activity
pii_lobbying_regulations | Regulation of lobbyist activity
pii_conflict_of_interest | Safeguards against conflicts of interest
pii_officials_postemployment | Post-employment activity of senior officials
pii_integrity_framework | Framework for public integrity in government institutions
pii_control_oversight | Oversight of internal control and internal audit functions
pii_control_regulations | Regulations for internal control, internal audit and risk management
pii_internal_audit | Internal audit activities in central government
pii_control_practices | Internal control and risk management practices

### Variable summary statistics

Variable | Countries | Year min | Year max | Value min | Value max
--- | ---: | ---: | ---: | ---: | ---:
pii_consultation_practices | 35 | 2022 | 2022 | 0.00 | 1.00
pii_proactive_disclosures | 36 | 2022 | 2022 | 0.40 | 0.93
pii_open_decisions | 36 | 2022 | 2022 | 0.00 | 1.00
pii_openness_functions | 36 | 2022 | 2022 | 0.00 | 1.00
pii_openness_regulations | 36 | 2022 | 2022 | 0.23 | 0.85
pii_lobbbying_transparency | 36 | 2022 | 2022 | 0.00 | 1.00
pii_lobbying_regulations | 36 | 2022 | 2022 | 0.29 | 0.92
pii_conflict_of_interest | 35 | 2022 | 2022 | 0.00 | 0.89
pii_officials_postemployment | 34 | 2022 | 2022 | 0.00 | 1.00
pii_integrity_framework | 35 | 2023 | 2023 | 0.00 | 6.33
pii_control_oversight | 29 | 2023 | 2023 | 0.00 | 1.58
pii_control_regulations | 29 | 2023 | 2023 | 0.30 | 3.00
pii_internal_audit | 29 | 2023 | 2023 | 0.00 | 4.00
pii_control_practices | 28 | 2023 | 2023 | 0.00 | 1.49

## Processing notes

The data is downloaded from the OECD's Data API and stored in a CSV file in
this folder.
