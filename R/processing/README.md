Blavatnik Index of Public Administration 2024: Source data processing > R scripts

# Processing scripts

The scripts in this folder process the source data for the Blavatnik Index of
Public Administration including data used in the Index calculation and other
contextual data. Each script handles to processing of a specific source and
produce a standardised output that can be read and used by the code to
calculate the Index results.

## Input
The source data for the processing is stored within the
[`data_raw`](../../data_raw/) folder, within this folder each individual source
has its own sub-folder that contains the raw data file(s), supporting
methodology documentation, and a `README.md` file that describes the data and
discusses processing.

### Pre-processing
Some of the source data requires pre-processing, please see the scripts in the
[`preprocessing`](../preprocessing/) folder for details. The data from
pre-processing is stored in the relevant folder within the `data_raw` folder.

## Output
Each script produces a CSV file.

For outputs for use in the calculation of the
Index these are "long" format files where each line relates to an individual
data point, with four columns:

- `cc_iso3c`: a 3-character alphabetic code identifying the country/territory,
  based on the ISO 3166-1 standard
- `ref_year`: a 4-digit number providing the reference year of the data point
- `variable`: a variable label that provides a unique reference to the data
  series the data point is drawn from
- `value`: the numeric value of the data point

Contextual data is either output in this format or in a "wide" format where
the columns represent variables.

## Dependencies
The processing scripts have the following R package dependencies:

- [`{countrycode}`](https://vincentarelbundock.github.io/countrycode/)
- [`{dplyr}`](https://dplyr.tidyverse.org)
- [`{haven}`](https://haven.tidyverse.org)
- [`{janitor}`](https://sfirke.github.io/janitor/)
- [`{lubridate}`](https://lubridate.tidyverse.org)
- [`{purrr}`](https://purrr.tidyverse.org/)
- [`{readr}`](https://readr.tidyverse.org)
- [`{readxl}`](https://readxl.tidyverse.org)
- [`{stringi}`](https://stringi.gagolewski.com/)
- [`{stringr}`](https://stringr.tidyverse.org)
- [`{tibble}`](https://tibble.tidyverse.org/)
- [`{tidyr}`](https://tidyr.tidyverse.org)
- [`{tidyxl}`](https://nacnudus.github.io/tidyxl/)
