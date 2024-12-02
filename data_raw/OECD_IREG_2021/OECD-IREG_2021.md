# OECD Indicators of Regulatory Policy and Governance (iREG)

Metadata | Value
--- | ---
Name | Indicators of Regulatory Policy and Governance
Publication date | 2021-12-06
Reference date | 2021
Publisher | OECD
Publisher URL | https://www.oecd.org/
Publication site | https://www.oecd.org/en/topics/measuring-regulatory-performance.html
Publication page | https://www.oecd.org/en/topics/measuring-regulatory-performance.html
Source file | `oecd_ireg_2021_indicators.csv`
Source URL | https://data-explorer.oecd.org/vis?fs[0]=Topic%2C1%7CPublic%20governance%23GOV%23%7CRegulation%23GOV_REG%23&pg=0&fc=Topic&bp=true&snb=2&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_QDD_GOV_REG%40DF_GOV_REG&df[ag]=OECD.GOV.GIP&df[vs]=1.0&dq=A.AUS...&pd=2014%2C&to[TIME_PERIOD]=false
Source format | CSV (.csv)
Copyright/licence | Re-use permitted for any purpose, https://www.oecd.org/en/about/terms-conditions.html
Pre-processing script | `OECD_IREG_2021_preprocess.R`
Processing script | `OECD_IREG_2021.R`

## About the data

The OECD's Indicators of Regulatory Governance provide a detailed assessment
of policy and regulatory practices in OECD member countries.

## Extracted variables

6 variables are extracted

### Variable definition

Variable | Description
--- | ---
ireg_primary_evaluation | Use of evaluation for primacy legislation
ireg_primary_ria | Use of impact assessment for primary legislation
ireg_primary_stakeholders | Stakeholder engagement practices for primary legislation
ireg_secondary_evaluation | Use of evaluation for secondary legislation
ireg_secondary_ria | Use of impact assessment for secondary legislation
ireg_secondary_stakeholders | Stakeholder engagement practices for secondary legislation

### Variable summary statistics

Variable | Countries | Year min | Year max | Value min | Value max
--- | ---: | ---: | ---: | ---: | ---:
ireg_primary_evaluation | 43 | 2021 | 2021 | 0.040 | 3.110
ireg_primary_ria | 41 | 2021 | 2021 | 0.200 | 3.650
ireg_primary_stakeholders | 41 | 2021 | 2021 | 0.570 | 3.250
ireg_secondary_evaluation | 43 | 2021 | 2021 | 0.040 | 3.130
ireg_secondary_ria | 43 | 2021 | 2021 | 0.360 | 3.640
ireg_secondary_stakeholders | 43 | 2021 | 2021 | 0.740 | 3.170

## Processing notes

The IREG data is downloaded from the OECD's Data API and stored as a CSV file
in this folder.
