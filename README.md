# Blavatnik Index of Public Administration 2024: source data processing

This repository contains the code for processing the original sources for the
[Blavatnik Index of Public Administration](https://index.bsg.ox.ac.uk).

## Copyright and licensing

The Blavatnik Index of Public Administration is copyright of the Blavatnik
School of Government, University of Oxford. The results of the Index, this
report, any visualisations and articles associated with the Index produced by
the Blavatnik School of Government are licensed under CC BY 4.0,
https://creativecommons.org/licenses/by/4.0/. The software and source code
is released under the MIT License.

When re-using the Index data or associated materials, please cite the work
appropriately:
> Blavatnik Index of Public Administration 2024, Blavatnik School of
> Government, University of Oxford, https://index.bsg.ox.ac.uk

The MIT license applies to the code contained within the R scripts stored in
this repository.

The data stored in the [`data_raw`](data_raw/) folder remains subject to the
copyright and licensing conditions of the original owners (see below). The
data stored in the [`data_context`](data_context/) and [`data_out`](data_out/)
is intermediate processing of the data stored in `data_raw`, in many cases it
is a simple standardisation of the original sources but in some cases there
has been notable reprocessing of the data. The contents of `data_out` should
only be used in conjunction with the main
[`bipa2024_index`](https://github.com/blavatnik-index/bipa2024_index/)
repository used to calculate the Blavatnik Index and its components are is not
intended for reuse in any other context.

### Disclaimer

The retention and storage of original source data in the `data_raw` and
`data_out` is intended only to support reproducibility and ensure transparency
of the methodology used to calculate the Blavatnik Index. The data is presented
"as is", without warranty of any kind and accepting no liability arising from
any use of the work.

### Original source licensing

The original source data used to compile the Blavatnik Index of Public
Administration remains subject to licence terms of the original third-party
authors, please consult the original materials for specific licence terms and
conditions relating to each source.

## Purpose

The purpose of the code in this repository is to extract data from the sources
that are used to calculate the Blavatnik Index of Public Administration, and
in particular to store the data in a consistent and common format for ease of
further processing and calculation.

Many sources are simply extracted and stored in the common format, but some
sources require pre-processing or have significant re-processing of the
original source data.

## Workflow

There are two main scripts in this repository:

- [`bulk_preprocess.R`](bulk_preprocess.R) conducts pre-processing
  (downloading from APIs, extracting data from PDFs) for some sources and saves
  the outputs of this pre-processing as CSV files back into the `data_raw`
  folder. For reproducibility these CSV files are stored in the repository and
  it is not advised to re-run this script after publication. It runs all the
  individual scripts in the [`R/preprocessing/`](R/preprocessing/) folder.
- [`bulk_process.R`](bulk_process.R) conducts the processing of the original
  source data, extracting variables and producing standardised output. It runs
  all the individual scripts in the [`R/processing/`](R/processing/) folder.

### Pre-processing

Some sources require pre-processing (downloading from APIs, extracting data
from PDFs), the outputs of this are saved back in the relevant sub-folder
within the `data_raw` folder for using the main processing scripts.

For reproducibility purposes it is not advised to re-run either the
`bulk_preprocessing.R` script after publication. Post-publication caution
should be taken when running any of the pre-processing scripts that call APIs
so that the original data used in the calculation of the Index are not
overwritten.

See the [README](R/preprocessing/) in the pre-processing folder for more
details.

### Processing

The processing of sources is handled by the scripts in the
[R/processing](R/processing/) folder. These should be viewed in conjunction
with the markdown documentation file in the `data_raw` folder and the Index's
[methodology documents](https://index.bsg.ox.ac.uk/methodology/).

### Utility functions

There are a number of bespoke utility functions in the [R/utils](R/utils/)
folder, see the [README](R/utils/README.md) for further details on these
functions.

### Data from the SGI and BTI sources

Owing to licensing conditions the original data for the SGI and BTI sources
is not stored in this repository on Github. Please consult the relevant
documentation file in the relevant `data_raw` sub-folders to access the
original sources yourself.

## Dependencies

This repository has two types of dependencies: (a) the related repositories
that containing reference lists, and (b) a number of R software packages.

### Related repositories and data

In order to run the code in this repository you will need the related
[`bipa2024_cartography`](https://github.com/blavatnik-index/bipa2024_cartography)
repository which contains geographic reference information. It should be stored
in the same containing folder as this one.

### R package dependencies

The code for the Blavatnik Index makes heavy use of R's native pipe therefore a
version of R at 4.1 or is necessary, The code has been developed using versions
of R from 4.3.3 through to 4.4.2, no testing of the code using versions of R
earlier than 4.3.3 have been made.

R package dependencies are managed via
[`{renv}`](https://rstudio.github.io/renv/articles/renv.html). If you
do not already have `{renv}` installed in your R setup then it will be
automatically installed when you first open the project. To load the
project dependencies run `renv::restore()` after the project has first loaded.

The core packages used by the Index are:

- [`{callr}`](https://CRAN.R-project.org/package=callr)	[3.7.6]
- [`{cli}`](https://CRAN.R-project.org/package=cli)	[3.6.3]
- [`{clipr}`](https://CRAN.R-project.org/package=clipr)	[0.8.0]
- [`{countrycode}`](https://CRAN.R-project.org/package=countrycode)	[1.6.0]
- [`{dplyr}`](https://CRAN.R-project.org/package=dplyr)	[1.1.4]
- [`{fs}`](https://CRAN.R-project.org/package=fs)	[1.6.4]
- [`{haven}`](https://CRAN.R-project.org/package=haven)	[2.5.4]
- [`{httr2}`](https://CRAN.R-project.org/package=httr2)	[1.0.1]
- [`{janitor}`](https://CRAN.R-project.org/package=janitor)	[2.2.0]
- [`{lubridate}`](https://CRAN.R-project.org/package=lubridate)	[1.9.3]
- [`{pdftools}`](https://CRAN.R-project.org/package=pdftools)	[3.4.0]
- [`{purrr}`](https://CRAN.R-project.org/package=purrr)	[1.0.2]
- [`{readr}`](https://CRAN.R-project.org/package=readr)	[2.1.5]
- [`{readxl}`](https://CRAN.R-project.org/package=readxl)	[1.4.3]
- [`{renv}`](https://CRAN.R-project.org/package=renv)	[1.0.7]
- [`{rlang}`](https://CRAN.R-project.org/package=rlang)	[1.1.4]
- [`{stringi}`](https://CRAN.R-project.org/package=stringi)	[1.8.4]
- [`{stringr}`](https://CRAN.R-project.org/package=stringr)	[1.5.1]
- [`{tibble}`](https://CRAN.R-project.org/package=tibble)	[3.2.1]
- [`{tidyr}`](https://CRAN.R-project.org/package=tidyr)	[1.3.1]
- [`{tidyxl}`](https://CRAN.R-project.org/package=tidyxl)	[1.0.10]
- [`{xml2}`](https://CRAN.R-project.org/package=xml2)	[1.3.6]
