#' Get a table of tracked time within a range of dates
#'
#' Get a table of tracked time (as a \code{tbl_df}
#' object). The date range or number of days back
#' from the present day can be specified to filter
#' the table returned. Otherwise, all tracked time
#' records are provided.
#' @param s minimum day for which tasks are to be
#' collected. Date must be in ISO format:
#' \code{YYYY-MM-DD}.
#' @param e maximum day for which tasks are to be
#' collected. Date must be in ISO format:
#' \code{YYYY-MM-DD}.
#' @param last_n_days a number of days back from the
#' current day for which tasks are to be collected.
#' @examples
#' \dontrun{
#' # Show all tracked tasks as a tibble
#' get_tt()
# A tibble: 3 x 8
#'   task                    s_d        s_t   e_d    e_t   lbl   proj   info
#'   <chr>                   <chr>      <chr> <chr>  <chr> <chr> <chr>  <chr>
#' 1 Description of the task 2018-05-24 11:30 2018-… 12:00 label proje… Any a…
#' 2 Description of the task 2018-05-24 12:00 2018-… 12:30 label proje… Any a…
#' 3 Description of the task 2018-05-24 12:30 2018-… 13:00 label proje… Any a…
#' }
#' @importFrom readr read_csv
#' @importFrom dplyr bind_rows mutate filter select
#' @export
get_tt <- function(s = NULL,
                   e = NULL,
                   last_n_days = NULL) {

  s_d <- s_d_date <- NULL

  ttt_file_list <- show_ttt_files(full_names = TRUE)

  for (i in seq(ttt_file_list)) {

    if (i == 1) {
      ttt_tbl <-
        ttt_file_list[i] %>%
        readr::read_csv(col_types = "cccccccc")
    }

    if (i > 1) {
      ttt_tbl <-
        dplyr::bind_rows(
          ttt_tbl,
          ttt_file_list[i] %>%
            readr::read_csv(col_types = "cccccccc"))
    }
  }

  if (is.null(last_n_days)) {

    if (!is.null(s)) {

      ttt_tbl <-
        ttt_tbl %>%
        dplyr::mutate(s_d_date = as.Date(s_d)) %>%
        dplyr::filter(s_d_date >= s) %>%
        dplyr::select(-s_d_date)
    }

    if (!is.null(e)) {

      ttt_tbl <-
        ttt_tbl %>%
        dplyr::mutate(s_d_date = as.Date(s_d)) %>%
        dplyr::filter(s_d_date <= e) %>%
        dplyr::select(-s_d_date)
    }

  } else {

    ttt_tbl <-
      ttt_tbl %>%
      dplyr::mutate(s_d_date = as.Date(s_d)) %>%
      dplyr::filter(s_d_date >= (Sys.Date() - as.difftime(last_n_days, units = "days"))) %>%
      dplyr::select(-s_d_date)
  }

  ttt_tbl
}
