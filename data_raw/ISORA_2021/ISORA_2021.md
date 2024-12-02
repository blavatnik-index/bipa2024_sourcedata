# International Survey of Revenue Administration (2021)

Metadata | Value
--- | ---
Name | International Survey of Revenue Administration (2021)
Publication date | multiple
Reference date | 2018-2021
Publisher | CIAT, IMF, IOTA, OECD
Publisher URL | https://www.imf.org
Publication site | https://data.rafit.org/
Publication page | https://data.rafit.org/
Source file | `ISORA_Form_A_2018_to_2021.xlsx`, `ISORA_Form_B_2018_to_2021.xlsx`, `ISORA_Form_C_2018_to_2021.xlsx`, `ISORA_Form_D_2018_to_2021.xlsx`, `ISORA_Form_E_2018_to_2021.xlsx`, `ISORA_Form_F_2018_to_2021.xlsx`, `ISORA_Form_G_2018_to_2021.xlsx`
Source URL | https://data.rafit.org/
Source format | Excel (.xlsx)
Other files | `ISORA 2022 English.pdf`, `ISORA 2022 Guide Glossary and Questionnaire English.pdf`
Copyright/licence | Re-use permitted, https://datahelp.rafit.org/knowledgebase/articles/1809769
Processing script | `ISORA_2021.R`

## About the data

The International Survey of Revenue Administration (ISORA) is a joint exercise
conducted by Inter-American Center for Tax Administration (CIAT); the
International Monetary Fund (IMF); the Intra-European Organization of Tax
Administrations (IOTA); and, the Organization for Economic Co-operation and
Development (OECD). The ISORA is an annual survey of tax administrations that
collects data about the operation of national tax systems, while much of the
data relates to tax rates and the amount of taxes collected it also contains
data relating to the operation and functioning of the tax agency itself.

The data is downloaded from the IMF's RA-FIT portal in six spreadsheets, each
relating to a separate section of the ISORA questionnaire:

- ISORA Form A - https://data.rafit.org/?sk=b5021f8a-ef07-4e9b-9a58-520a005b9509&hide_uv=1
- ISORA Form B - https://data.rafit.org/?sk=160b883b-6c32-458c-885c-e2402e9cf0ff&hide_uv=1
- ISORA Form C - https://data.rafit.org/?sk=d1ea8ce6-4dbe-4d33-893a-dd5573c6a819&hide_uv=1
- ISORA Form D - https://data.rafit.org/?sk=97a3903a-c3ba-46cf-a2a0-1458a7e33431&hide_uv=1
- ISORA Form E - https://data.rafit.org/?sk=e554b055-9fb6-4f01-abef-cbf9f96e2207&hide_uv=1
- ISORA Form F - https://data.rafit.org/?sk=1624d942-76cb-4cb9-8e3a-c105512849ac&hide_uv=1
- ISORA Form G - https://data.rafit.org/?sk=14c9c0e0-73ff-4283-a1e5-22831206e340&hide_uv=1

## Extracted variables

14 variables are extracted

### Variable definition

Variable | Description
--- | ---
isora_admin_costs | Administrative costs as a proportion of net revenue
isora_digital_contacts | Proportion of service contacts via digital channels
isora_electronic_corporate | Proportion of corporate tax filings made electronically
isora_electronic_payments | Proportion of payments made electronically
isora_electronic_personal | Proportion of personal tax filings made electronically
isora_execs_female | Proportion of tax agency senior officials that are female
isora_filing_corporate | Proportion of corporate tax filings made on-time
isora_filing_personal | Proportion of personal tax filings made on-time
isora_fte_female | Proportion of all tax agency officials that are female
isora_fte_turnover | Turnover
isora_innovative_practices | Use of innovative practices and technologies by tax agencies
isora_payments_corporate | Proportion of corporate taxes paid on-time
isora_payments_personal | Proportion of personal taxes paid on-time
isora_tax_debt | Tax debt as a proportion of net revenue

### Variable summary statistics

Variable | Countries | Year min | Year max | Value min | Value max
--- | ---: | ---: | ---: | ---: | ---:
isora_admin_costs | 159 | 2019 | 2021 | 0.001 | 0.151
isora_digital_contacts | 129 | 2019 | 2021 | 0.000 | 1.000
isora_electronic_corporate | 143 | 2018 | 2021 | 0.000 | 1.000
isora_electronic_payments | 156 | 2019 | 2021 | 0.000 | 1.000
isora_electronic_personal | 137 | 2018 | 2021 | 0.000 | 1.000
isora_execs_female | 163 | 2019 | 2021 | 0.000 | 1.000
isora_filing_corporate | 155 | 2018 | 2021 | 0.020 | 1.000
isora_filing_personal | 145 | 2018 | 2021 | 0.003 | 1.000
isora_fte_female | 170 | 2019 | 2021 | 0.026 | 0.875
isora_fte_turnover | 165 | 2019 | 2021 | 0.000 | 0.250
isora_innovative_practices | 172 | 2019 | 2021 | 0.000 | 10.000
isora_payments_corporate | 122 | 2018 | 2021 | 0.000 | 1.000
isora_payments_personal | 119 | 2018 | 2021 | 0.000 | 1.000
isora_tax_debt | 152 | 2019 | 2021 | 0.000 | 2.904

## Processing notes

The re-processing of the data in order to calculate proportions, coerce
categorical data into numerical values, and exclude outlier values.