
source("R/utils/run_scripts.R")

archive_files()

processing_scripts <- dir(
  "R/processing", pattern = "\\.R$",
  full.names = TRUE
)

run_scripts(processing_scripts)


