Blavatnik Index of Public Administration 2024: Source data processing > R scripts

# Preprocessing scripts

The scripts in this folder pre-process the source data for the Blavatnik Index
of Public Administration. The pre-processing scripts handle two issues:

- data that needs to be downloaded from a web API source
- data that needs to be extracted from a PDF document

The pre-processing scripts download/extract the data and store it in a CSV file
so that it can be handled by the scripts in the [`processing`](../processing/)
folder.

## Input
The source data for the pre-processing are stored within the
[`data_raw`](../../data_raw/) folder, within this folder each individual source
has its own sub-folder that contains the raw data file(s), supporting
methodology documentation, and a `README.md` file that describes the data and
discusses processing.

## Output
Each script produces a CSV file.

## Dependencies
The pre-processing scripts (including utility scripts) have the following R
package dependencies:

- [`{cli}`](https://cli.r-lib.org)
- [`{countrycode}`](https://vincentarelbundock.github.io/countrycode/)
- [`{dplyr}`](https://dplyr.tidyverse.org)
- [`{httr2}`](https://httr2.r-lib.org,)
- [`{pdftools}`](https://docs.ropensci.org/pdftools/)
- [`{purrr}`](https://purrr.tidyverse.org/)
- [`{readr}`](https://readr.tidyverse.org)
- [`{rlang}`](https://rlang.r-lib.org)
- [`{tibble}`](https://tibble.tidyverse.org/)
- [`{tidyr}`](https://tidyr.tidyverse.org)
- [`{xml2}`](https://xml2.r-lib.org/)