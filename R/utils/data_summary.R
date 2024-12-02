# summarise contents of a long dataset
data_summary <- function(x) {
  x |>
    dplyr::arrange(variable) |>
    dplyr::summarise(
      n_countries = dplyr::n(),
      year_min = min(ref_year),
      year_max = max(ref_year),
      value_min = round(min(value), 3),
      value_max = round(max(value), 3),
      .by = variable
    )
}

# easily copy a summary to the clipboard for easy pasting into
# markdown documentation for datasets
copy_data_summary <- function(x) {
  data_summary(x) |>
    clipr::write_clip(col.names = FALSE, sep = " | ")
}
