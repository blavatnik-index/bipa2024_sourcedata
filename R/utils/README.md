Blavatnik Index of Public Administration 2024: Source data processing > R scripts

# Utility scripts

The scripts in this folder are utility scripts to assist in the processing of
the source data for the Blavatnik Index of Public Administration.

There are 7 scripts: one script that assists in the running of the processing
scripts, one script that loads the reference list of countries and other
geographic entities, one script that writes a standardised CSV file, and four
scripts that manage calls to web API services.

## `run_scripts.R`
The [`run_scripts.R`](run_scripts.R) file contains the `run_scripts()` function
used in the [`bulk_preprocess.R`](../../bulk_preprocess.R) and
[`bulk_process.R`](../../bulk_process.R) scripts. `run_scripts()` acts as
a wrapper around the
[`callr::rscript()`](https://callr.r-lib.org/reference/rscript.html) function
to process a script/set of scripts in their own self-contained R session(s), it
also provides a progress bar for end-user convenience.

## `country_codes.R`
The [`country_codes.R`](country_codes.R) file loads the reference list of
country and other geographic entities, and contains two convenience functions
used in the development of the processing scripts.

The reference list is documented in the separate
(`bipa-cartography`)[]
repository. It contains a unique list of 3-character codes for geographic
entities derived from the ISO 3166-1 alpha-3 standard.

The `check_codes()` function takes a vector of country codes and checks it
against the reference list. It it is used in the development and production
stages of the index. In the development stages it was used to identify codes
not contained in the reference list, typically for codes relating to entities
not covered by the ISO standard (e.g. Kosovo, or the inclusion of subnational
as well as national data). In production stages it is used to check no invalid
codes are included in the output dataset before it is written to the
[`data_out`](../../data_out/) or [`data_context`](../../data_context/) folders.

The `missing_codes()` function also takes a vector of country codes and
compares it to the reference list. It was used in the development stages to
investigate which geographic entities were not included in the dataset. It is
not used in the production stage.

## `write_standard_csv.R`
The [`write_standard_csv.R`](write_standard_csv.R) file contains the
`write_standard_csv()` function which is a wrapper around the
[`readr::write_excel_csv()`](https://readr.tidyverse.org/reference/write_delim.html)
function for use when saving the outputs of processing scripts, it conducts
checks on the data.frame it is passed to ensure it conforms to the required
output standard:

- there are 4 columns: `cc_iso3c`, `ref_year`, `variable`, and `value`
- the `cc_iso3c` column is a character vector with values comprising only
  3 characters and all characters are upper case A-Z, validity of country
  codes should be checked separately with the `check_codes()` function
  described above
- the `ref_year` column is a numeric vector with values only 4 digits in length
- the `variable` column is a character vector
- the `value` column is a numeric vector

## API callers
There are four scripts that provide functions to handle calls to and output
from web API services. These are used by the scripts in the
[`preprocessing`](../preprocessing/) folder to download data from the API
services.

### `ilo_api.R`
The [`ilo_api.R`](ilo_api.R) file provides two functions to access files
provided by the International Labor Organization's
[bulk download facility](https://ilostat.ilo.org/data/bulk/).

The `ilo_api_download()` function downloads the data file for a particular
indicator. The `ilo_dic_download()` function downloads the data dictionary file
related to a particular indicator. Both functions save their downloads to the
[`data_raw/ILOSTAT_2024`](../../data_raw/ILOSTAT_2024/) folder.

### `oecd_api.R`
The [`oecd_api.R`](oecd_api.R) file provides three functions relating to the
OECD's [API service](https://data.oecd.org/api/) which provides access to the
data contained in the OECD's [Data Explorer](https://data-explorer.oecd.org)
service.

The `oecd_api_data()` function returns data for a given indicator/dataset.
The `oecd_api_meta()` function returns metadata for a given indictor/dataset,
while the `oecd_xml_metadata()` function takes the XML metadata file returned
by `oecd_api_meta()` and converts it into a CSV file.

The functions require explicit output file locations, these are specified in
the individual function calls but will be sub-folders within the
[`data_raw/OECD`](../../data_raw/OECD/) folder.

### `unsdg_api.R`
The [`unsdg_api.R`](unsdg_api.R) file returns data from the API service
associated with the United Nations'
[SDG Indicators Database](https://unstats.un.org/sdgs/dataportal).

The `unsdg_api()` function returns a CSV file for a given indicator series. It
is used only once to obtain data relating to the Sendai Framework for Action
Monitoring system, this data is stored in the
[`data_raw/SFM_2023`](../../data_raw/SFM_2023/) folder.

### `wb_api.R`
The [`wb_api.R`] file returns data from the World Bank's data API service.

The `wb_api_call()` function returns data for a specific indicator and returns
this as a data.frame which the pre-processing scripts then save as a CSV in
the relevant sub-folder within the [`data_raw`](../../data_raw/) folder.

## Dependencies
The utility scripts have the following R package dependencies:

- [`{callr}`](https://callr.r-lib.org, https://github.com/r-lib/callr)
- [`{cli}`](https://cli.r-lib.org, https://github.com/r-lib/cli)
- [`{dplyr}`](https://dplyr.tidyverse.org, https://github.com/tidyverse/dplyr)
- [`{httr2}`](https://httr2.r-lib.org, https://github.com/r-lib/httr2)
- [`{purrr}`](https://purrr.tidyverse.org/, https://github.com/tidyverse/purrr)
- [`{readr}`](https://readr.tidyverse.org, https://github.com/tidyverse/readr)
- [`{rlang}`](https://rlang.r-lib.org, https://github.com/r-lib/rlang)
- [`{tibble}`](https://tibble.tidyverse.org/, https://github.com/tidyverse/tibble)
- [`{xml2}`](https://xml2.r-lib.org/, https://github.com/r-lib/xml2)