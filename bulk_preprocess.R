
source("R/utils/run_scripts.R")

preprocess_scripts <- dir(
  "R/preprocessing",
  pattern = "\\.R$",
  full.names = TRUE, recursive = TRUE
)

run_scripts(preprocess_scripts)
