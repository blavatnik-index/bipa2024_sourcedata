cc_full_list <- suppressMessages(readr::read_csv(
  "../bipa2024-cartography/entity_codes/entity_codes.csv",
))

check_codes <- function(cc_list, .stop = FALSE, .success = TRUE) {

  stopifnot(rlang::is_character(cc_list))

  cc_unq <- unique(cc_list)

  bad_cc <- cc_unq[!(cc_unq %in% cc_full_list$cc_iso3c)]

  if (length(bad_cc) > 0) {

    bad_cc_msg <- "Invalid codes detected: {.val {bad_cc}}"

    if (.stop) {
      cli::cli_abort(
        c(x = bad_cc_msg)
      )
    } else {
      cli::cli_alert_danger(bad_cc_msg)
    }

  } else if (.success) {
    cli::cli_alert_success("No invalid codes detected")
  }

  return(invisible(bad_cc))

}

missing_codes <- function(cc_list, show = FALSE) {

  stopifnot(rlang::is_character(cc_list))

  cc_unq <- unique(cc_list)

  missing_cc <- cc_full_list$cc_iso3c[!(cc_full_list$cc_iso3c %in% cc_unq)]
  missing_names <- cc_full_list$cc_name_short[cc_full_list$cc_iso3c %in% missing_cc]

  if (length(missing_cc) > 0) {
    cli::cli_alert_info(
      c("There are {length(cc_unq)} codes included and {length(missing_cc)} ",
        "codes not included in the supplied list")
    )

    if (show) {
      cli::cli_text("Missing codes:")
      cli::cli_ul(paste(missing_cc, missing_names, sep = " - "))
    }
  }

}
