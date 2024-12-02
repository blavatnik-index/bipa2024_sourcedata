
run_scripts <- function(scripts) {

  if (interactive()) {
    cli::cli_progress_bar(
      total = length(scripts),
      format = "Script {cli::pb_current}/{cli::pb_total} {cli::pb_bar} | {cli::pb_eta_str}",
      format_done = "Processed {cli::pb_total} scripts in {cli::pb_elapsed}",
      clear = FALSE
    )
  }

  for (s in scripts) {
    callr::rscript(s, show = FALSE)
    if (interactive()) cli::cli_progress_update()
  }

}

archive_files <- function() {
  if (interactive()) {
    archive_files <- menu(
      c(
        "Yes, archive the existing files",
        "No, do not archive the existing files"
      ),
      title = "Do you want to archive the existing files in `data_context` and `data_out`"
    )
  } else {
    archive_files <- 1
  }
  
  if (archive_files == 1) {
    output_files <- fs::dir_ls(path = "data_out", regexp = "\\.csv$")
    context_files <- fs::dir_ls(path = "data_context", regexp = "\\.csv$")
    archive_ts <- strftime(Sys.time(), "%Y%m%d%H%M%S")
  
    if (length(output_files) > 0) {
      archive_out <- file.path("data_out", ".old", archive_ts)
      if (!fs::dir_exists(archive_out)) {
        fs::dir_create(archive_out, recurse = TRUE)
      }
      fs::file_move(output_files, archive_out)
      cli::cli_alert_success(
        "Existing output files have been archived and transferred to {.strong {archive_out}}"
      )
    }
  
    if (length(context_files) > 0) {
      archive_context <- file.path("data_context", ".old", archive_ts)
      if (!fs::dir_exists(archive_context)) {
        fs::dir_create(archive_context, recurse = TRUE)
      }
      fs::file_move(context_files, archive_context)
      cli::cli_alert_success(
        "Existing context files have been archived and transferred to {.strong {archive_context}}"
      )
    }
  
    if (length(output_files) + length(context_files) == 0) {
      cli::cli_alert_info("No files to archive")
    }
  
  } else if (archive_files == 1) {
    cli::cli_alert_warning("Existing files will not be deleted and may be overwritten")
  } else {
    cli::cli_abort("Processing aborted")
  }
}
