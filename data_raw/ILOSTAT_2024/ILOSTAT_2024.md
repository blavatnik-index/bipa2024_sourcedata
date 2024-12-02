# ILOSTAT

Metadata | Value
--- | ---
Name | ILO Statistics (ILOSTAT)
Publication date | continuous (2024-06-06)
Reference date | continuous
Publisher | International Labor Organization
Publisher URL | https://www.ilo.org
Publication site | https://ilostat.ilo.org
Publication page | https://ilostat.ilo.org/data/bulk/
Source file | multiple 
Source URL | https://ilostat.ilo.org/data/bulk/
Source format | CSV (.csv)
Copyright/licence | CC-BY-4.0
Pre-processing script | `ILOSTAT_2024_preprocess.R`
Processing script | `ILOSTAT_2024.R`

## About the data

The International Labor Organization (ILO) collates labour market statistics
from national statistical institutes. The data they collect includes
statistics relating to the composition of the public sector, this is used by
the Index for measures of gender representation and gender pay ratios. Data is
also collected on the relative size of public administrations.

## Extracted variables

13 variables are extracted, 5 of these are used in the calculation of the Index
and 8 are extracted as contextual variables for further analysis.

### Variable definition

Variable | Description
--- | ---
ilo_ps_mgrpro_female | Proportion of public sector managers that are female
ilo_ps_payratio | Ratio of female hourly pay to male hourly pay in the public sector
ilo_ps_snrmgr_female | Proportion of public sector senior managers that are female
ilo_pse_female | Proportion of public sector employees that are female
ilo_pubad_female | Proportion of public administration employees that are female
ilo_rate_pse_cengov | Central government employment as a percentage of public sector employment
ilo_rate_pse_pubad | Public administration employment as a percentage of public sector employment
ilo_rate_total_cengov | Central government employment as a percentage of total employment
ilo_rate_total_pse | Public sector employment as a percentage of total employment
ilo_rate_total_pubad | Public administration employment as a percentage of total employment
ilo_size_cengov | Central government employment (total)
ilo_size_pse | Public sector employment (total)
ilo_size_pubad | Public administration employment (total)

### Variable summary statistics

Variable | Countries | Year min | Year max | Value min | Value max
--- | ---: | ---: | ---: | ---: | ---:
ilo_ps_mgrpro_female | 125 | 2015 | 2023 | 0.106 | 0.669
ilo_ps_payratio | 78 | 2015 | 2023 | 0.609 | 2.394
ilo_ps_snrmgr_female | 64 | 2017 | 2023 | 0 | 0.652
ilo_pse_female | 185 | 2015 | 2023 | 0.079 | 0.76
ilo_pubad_female | 167 | 2015 | 2023 | 0.027 | 0.643
ilo_rate_pse_cengov | 47 | 2016 | 2022 | 0.005 | 0.971
ilo_rate_pse_pubad | 114 | 2015 | 2023 | 0.001 | 0.855
ilo_rate_total_cengov | 42 | 2016 | 2022 | 0.001 | 0.686
ilo_rate_total_pse | 179 | 2015 | 2023 | 0.002 | 1
ilo_rate_total_pubad | 172 | 2015 | 2023 | 0 | 0.27
ilo_size_cengov | 58 | 2016 | 2022 | 0.717 | 48706
ilo_size_pse | 180 | 2015 | 2023 | 0.181 | 248896
ilo_size_pubad | 172 | 2015 | 2023 | 0.054 | 7134.908

## Processing notes

Data is downloaded from the ILO's
[bulk download facility](https://ilostat.ilo.org/data/bulk/) by the
pre-processing script. The CSV files contained in this folder are a record of
the downloads used by the Index. This data was downloaded on 6th June 2024
(2024-06-06).

Data is collected and submitted to the ILO using a number of different
classifications. To maximise country data coverage the processing scrip makes
pragmatic selection of variables, preferring the latest classifications of
public administration or government accounting, then switching to older
classifications before reverting to whole public sector measures.