
#' Get location of the ttt_dir
#'
#' Get the directory path for the hidden ttt directory.
#' @export
where_ttt_dir <- function() {

  path.expand("~/Documents/.ttt/")
}

#' Get a vector of files in ttt_dir
#'
#' Get a vector of all files in the ttt directory.
#' @param full_names an option for showing the
#' directory paths prepended to the file names.
#' full path
#' @export
show_ttt_files <- function(full_names = FALSE) {

  where_ttt_dir() %>% list.files(full.names = full_names)
}

#' Delete all files in ttt_dir
#'
#' Delete all of the files in the ttt directory.
#' @export
delete_all_ttt_files <- function() {

  file_count <-
    list.files(path = where_ttt_dir(), pattern = "*.csv") %>%
    length()

  invisible(
    file.remove(
      where_ttt_dir() %>%
      list.files(full.names = TRUE)))

  message(
    paste0(
      "All ", file_count, " CSV file(s) in `",
      where_ttt_dir(), "` have been removed"))
}

