#' Track Task (*tt*)
#'
#' Track a task by using \code{tt()}.
#' @param ... a string that allows for a shorthand means to
#' track time for some task.
#' @param task the task description.
#' @param s the start time for the task. Must be
#' in the ISO date/time format of \code{YYYY-MM-DD HH:MM}.
#' @param e the end time for the task. Must be
#' in the ISO date/time format of \code{YYYY-MM-DD HH:MM}.
#' @param lbl a label to use for the event.
#' @param proj project information for the event.
#' @param info information pertaining to the event.
#' @param write a logical value indicating whether the
#' tracked task entry should be written to disk.
#' @importFrom stringr str_squish str_detect str_split str_remove
#' @importFrom stringr str_extract str_extract_all str_replace
#' @importFrom dplyr tibble bind_rows arrange
#' @importFrom readr read_csv write_csv
#' @importFrom purrr map
#' @importFrom rlang flatten_chr
#' @export
tt <- function(...,
               task = NULL,
               s = NULL,
               e = NULL,
               lbl = NULL,
               proj = NULL,
               info = NULL,
               write = TRUE) {

  x_in <- list(...)

  if (length(x_in) > 0) {
    x_in <- x_in[[1]]
  }

  # Validate input for `s`, if provided
  if (!is.null(s)) {

    s_present <- TRUE
    s <- s %>% stringr::str_squish()

    if (s %>% stringr::str_detect(
      pattern = "[1-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-9]+\\:[0-5][0-9]")) {
      s_valid <- TRUE
    } else {
      s_valid <- FALSE
    }
  } else {
    s_present <- FALSE
  }

  # Validate input for `e`, if provided
  if (!is.null(e)) {

    e_present <- TRUE
    e <- e %>% stringr::str_squish()

    if (e %>% stringr::str_detect(
      pattern = "[1-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-9]+\\:[0-5][0-9]")) {
      e_valid <- TRUE
    } else {
      e_valid <- FALSE
    }
  } else {
    e_present <- FALSE
  }

  if (inherits(x_in, "character")) {

    quick_input <-
      x_in %>%
      stringr::str_split(";") %>%
      purrr::map(.f = stringr::str_squish) %>%
      rlang::flatten_chr()

    # Parse any task given (t.*?:)
    if (any(quick_input %>% stringr::str_detect(pattern = "^t.*?\\:")) &
        is.null(task)) {

      # Get the vector component relating to a task (t:)
      component_t <-
        (quick_input %>%
           stringr::str_detect(pattern = "^t.*?\\:") %>%
           which())[1]

      # Extract the task text from the quick input
      task <-
        quick_input[component_t] %>%
        stringr::str_remove("^t.*?\\:") %>%
        stringr::str_squish()
    }

    # Parse any start time given (s.*?:)
    if (any(quick_input %>% stringr::str_detect(pattern = "^s.*?\\:")) &
        (!s_present || !s_valid)) {

      # Get the vector component relating to a start time (s:)
      component_s <-
        (quick_input %>%
           stringr::str_detect(
             pattern = "^s.*?\\:") %>%
           which())[1]

      # Extract the start time text from the quick input
      start <-
        quick_input[component_s] %>%
        stringr::str_remove("^s.*?\\:") %>%
        stringr::str_squish()

      # Get current date and time if `now` is used
      if (start %>%
          stringr::str_detect(
            pattern = ".*now.*")) {

        s_t <- format(Sys.time(), "%H:%M") %>% stringr::str_squish()
        s_d <- format(Sys.time(), "%F") %>% stringr::str_squish()
      }

      # Parse time if present
      if (start %>% stringr::str_detect(pattern = ".*\\:.*") |
          start %>% stringr::str_detect(pattern = "([1-9]|[1-9][0-9])[ ]*?[a-zA-Z][a-zA-Z]")) {

        if (start %>% stringr::str_detect(pattern = ".*\\:.*")) {

          s_t_n <-
            (quick_input[component_s] %>%
               stringr::str_remove("^s.*?\\:") %>%
               stringr::str_extract_all(pattern = "[0-9]+\\:[0-9][0-9]"))[[1]]

        } else if (start %>% stringr::str_detect(pattern = "([1-9]|[1-9][0-9])[ ]*?[a-zA-Z][a-zA-Z]")) {

          s_t_n <-
            paste0(
              quick_input[component_s] %>%
                stringr::str_remove("^s.*?\\:") %>%
                stringr::str_extract(pattern = "[0-9]*"),
              ":00")
        }

        if (start %>%
            stringr::str_detect(
              pattern = ".*pm$|.*PM$|.*p$|.*P$")) {

          s_hour_part <-
            (s_t_n %>%
               stringr::str_split(pattern = ":") %>%
               unlist())[1] %>%
            as.numeric()

          if (s_hour_part > 12) {
            s_t <- s_t_n

          } else {
            s_t <-
              paste0(
                (s_hour_part + 12), ":",
                (s_t_n %>%
                   stringr::str_split(pattern = ":") %>%
                   unlist())[2])
          }

        } else if (start %>%
                   stringr::str_detect(
                     pattern = ".*am$|.*AM$|.*a$|.*A$")) {

          s_t <- s_t_n

        } else {
          s_t <- s_t_n
        }
      }

      # Parse date if present
      if (start %>%
          stringr::str_detect(
            pattern = ".*2[0-9][0-9][0-9](-|//)[0-1][0-9](-|//)[0-3][0-9].*")) {

        s_year <-
          start %>%
          stringr::str_replace(
            pattern = ".*(2[0-9][0-9][0-9])(-|//)([0-1][0-9])(-|//)([0-3][0-9]).*",
            replacement = "\\1")

        s_month <-
          start %>%
          stringr::str_replace(
            pattern = ".*(2[0-9][0-9][0-9])(-|//)([0-1][0-9])(-|//)([0-3][0-9]).*",
            replacement = "\\3")

        s_day <-
          start %>%
          stringr::str_replace(
            pattern = ".*(2[0-9][0-9][0-9])(-|//)([0-1][0-9])(-|//)([0-3][0-9]).*",
            replacement = "\\5")

        s_d <- paste0(s_year, "-", s_month, "-", s_day)

      } else if (start %>% stringr::str_detect(pattern = ".*yesterday.*")) {

        s_d <-
          format(Sys.time() - as.difftime(1, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (start %>% stringr::str_detect(pattern = ".*[0-9]+?[ ]*?d ago.*")) {

        s_days_back <-
          start %>%
          stringr::str_extract("[0-9]+?[ ]*?d ago") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        s_d <-
          format(Sys.time() - as.difftime(s_days_back, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (start %>% stringr::str_detect(pattern = ".*[0-9]+?[ ]*?d ahead.*")) {

        s_days_ahead <-
          start %>%
          stringr::str_extract("[0-9]+?[ ]*?d ahead") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        s_d <-
          format(Sys.time() + as.difftime(s_days_ahead, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (start %>% stringr::str_detect(pattern = ".*\\-[0-9]+?[ ]*?d.*")) {

        s_days_back <-
          start %>%
          stringr::str_extract("\\-[0-9]+?[ ]*?d") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        s_d <-
          format(Sys.time() - as.difftime(s_days_back, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (start %>% stringr::str_detect(pattern = ".*\\+[0-9]+?[ ]*?d.*")) {

        s_days_ahead <-
          start %>%
          stringr::str_extract("\\+[0-9]+?[ ]*?d") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        s_d <-
          format(Sys.time() + as.difftime(s_days_ahead, units ="days"), "%F") %>%
          stringr::str_squish()

      } else {
        s_d <- format(Sys.time(), "%F") %>% stringr::str_squish()
      }
    } else {
      s_d <- NA_character_
      s_t <- NA_character_
    }

    # Parse any end time given (e.*?:)
    if (any(quick_input %>% stringr::str_detect(pattern = "^e.*?\\:")) &
        (!e_present || !e_valid)) {

      # Get the vector component relating to an end time (e:)
      component_e <-
        (quick_input %>%
           stringr::str_detect(
             pattern = "^e.*?\\:") %>%
           which())[1]

      # Extract the end time text from the quick input
      end <-
        quick_input[component_e] %>%
        stringr::str_remove("^e.*?\\:") %>%
        stringr::str_squish()

      # Get current date and time if `now` is used
      if (end %>%
          stringr::str_detect(
            pattern = ".*now.*")) {

        e_t <- format(Sys.time(), "%H:%M") %>% stringr::str_squish()
        e_d <- format(Sys.time(), "%F") %>% stringr::str_squish()
      }

      # Parse time if present
      if (end %>% stringr::str_detect(pattern = ".*\\:.*") |
          end %>% stringr::str_detect(pattern = "([1-9]|[1-9][0-9])[ ]*?[a-zA-Z][a-zA-Z]")) {

        if (end %>% stringr::str_detect(pattern = ".*\\:.*")) {

          e_t_n <-
            (quick_input[component_e] %>%
               stringr::str_remove("^e.*?\\:") %>%
               stringr::str_extract_all(pattern = "[0-9]+\\:[0-9][0-9]"))[[1]]

        } else if (end %>% str_detect(pattern = "([1-9]|[1-9][0-9])[ ]*?[a-zA-Z][a-zA-Z]")) {

          e_t_n <-
            paste0(
              quick_input[component_e] %>%
                stringr::str_remove("^e.*?\\:") %>%
                stringr::str_extract(pattern = "[0-9]*"),
              ":00")
        }

        if (end %>%
            stringr::str_detect(
              pattern = ".*pm$|.*PM$|.*p$|.*P$")) {

          e_hour_part <-
            (e_t_n %>%
               stringr::str_split(pattern = ":") %>%
               unlist())[1] %>%
            as.numeric()

          if (e_hour_part > 12) {
            e_t <- e_t_n

          } else {
            e_t <-
              paste0(
                (e_hour_part + 12), ":",
                (e_t_n %>%
                   stringr::str_split(pattern = ":") %>%
                   unlist())[2])
          }

        } else if (end %>%
                   stringr::str_detect(
                     pattern = ".*am$|.*AM$|.*a$|.*A$")) {

          e_t <- e_t_n

        } else {
          e_t <- e_t_n
        }
      }

      # Parse date if present
      if (end %>%
          stringr::str_detect(
            pattern = ".*2[0-9][0-9][0-9](-|//)[0-1][0-9](-|//)[0-3][0-9].*")) {

        e_year <-
          end %>%
          stringr::str_replace(
            pattern = ".*(2[0-9][0-9][0-9])(-|//)([0-1][0-9])(-|//)([0-3][0-9]).*",
            replacement = "\\1")

        e_month <-
          end %>%
          stringr::str_replace(
            pattern = ".*(2[0-9][0-9][0-9])(-|//)([0-1][0-9])(-|//)([0-3][0-9]).*",
            replacement = "\\3")

        e_day <-
          end %>%
          stringr::str_replace(
            pattern = ".*(2[0-9][0-9][0-9])(-|//)([0-1][0-9])(-|//)([0-3][0-9]).*",
            replacement = "\\5")

        e_d <- paste0(e_year, "-", e_month, "-", e_day)

      } else if (end %>% stringr::str_detect(pattern = ".*yesterday.*")) {

        e_d <-
          format(Sys.time() - as.difftime(1, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (end %>% stringr::str_detect(pattern = ".*[0-9]+?[ ]*?d ago.*")) {

        e_days_back <-
          end %>%
          stringr::str_extract("[0-9]+?[ ]*?d ago") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        e_d <-
          format(Sys.time() - as.difftime(e_days_back, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (end %>% stringr::str_detect(pattern = ".*[0-9]+?[ ]*?d ahead.*")) {

        e_days_ahead <-
          end %>%
          stringr::str_extract("[0-9]+?[ ]*?d ahead") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        e_d <-
          format(Sys.time() + as.difftime(e_days_ahead, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (end %>% stringr::str_detect(pattern = ".*\\-[0-9]+?[ ]*?d.*")) {

        e_days_back <-
          end %>%
          stringr::str_extract("\\-[0-9]+?[ ]*?d") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        e_d <-
          format(Sys.time() - as.difftime(e_days_back, units ="days"), "%F") %>%
          stringr::str_squish()

      } else if (end %>% stringr::str_detect(pattern = ".*\\+[0-9]+?[ ]*?d.*")) {

        e_days_ahead <-
          end %>%
          stringr::str_extract("\\+[0-9]+?[ ]*?d") %>%
          stringr::str_extract("[0-9]+?") %>%
          as.numeric()

        e_d <-
          format(Sys.time() + as.difftime(e_days_ahead, units ="days"), "%F") %>%
          stringr::str_squish()

      } else {
        e_d <- format(Sys.time(), "%F") %>% stringr::str_squish()
      }
    } else {
      e_d <- NA_character_
      e_t <- NA_character_
    }

    # Parse any label given (l.*?:)
    if (any(quick_input %>% stringr::str_detect(pattern = "^l.*?\\:"))) {

      # Get the vector component relating to a label (l:)
      component_l <-
        (quick_input %>%
           stringr::str_detect(pattern = "^l.*?\\:") %>%
           which())[1]

      # Extract the label text from the quick input
      lbl <-
        quick_input[component_l] %>%
        stringr::str_remove("^l.*?\\:") %>%
        stringr::str_squish()
    }

    # Parse any project given (p.*?:)
    if (any(quick_input %>% stringr::str_detect(pattern = "^p.*?\\:"))) {

      # Get the vector component relating to a project (p:)
      component_p <-
        (quick_input %>%
           stringr::str_detect(pattern = "^p.*?\\:") %>%
           which())[1]

      # Extract the label text from the quick input
      proj <-
        quick_input[component_p] %>%
        stringr::str_remove("^p.*?\\:") %>%
        stringr::str_squish()
    }

    # Parse any information provided (i.*?:)
    if (any(quick_input %>% stringr::str_detect(pattern = "^i.*?\\:"))) {

      # Get the vector component relating to information (i:)
      component_i <-
        (quick_input %>%
           stringr::str_detect(pattern = "^i.*?\\:") %>%
           which())[1]

      # Extract the label text from the quick input
      info <-
        quick_input[component_i] %>%
        stringr::str_remove("^i.*?\\:") %>%
        stringr::str_squish()
    }
  }

  if (!is.null(s)) {

    if (s %>% stringr::str_detect(
      pattern = "^[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]$")) {

      s_d <- (s %>% stringr::str_split(pattern = " ") %>% unlist())[1]

      s_t <- (s %>% stringr::str_split(pattern = " ") %>% unlist())[2]
    }
  }

  if (!is.null(e)) {

    if (e %>% stringr::str_detect(
      pattern = "^[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]$")) {

      e_d <- (e %>% stringr::str_split(pattern = " ") %>% unlist())[1]

      e_t <- (e %>% stringr::str_split(pattern = " ") %>% unlist())[2]
    }
  }

  # Construct the table row
  tbl_row <-
    dplyr::tibble(
      task = ifelse(!is.null(task), task %>% as.character(), NA_character_),
      s_d = ifelse(exists("s_d"), s_d %>% as.character(), NA_character_),
      s_t = ifelse(exists("s_t"), s_t %>% as.character(), NA_character_),
      e_d = ifelse(exists("e_d"), e_d %>% as.character(), NA_character_),
      e_t = ifelse(exists("e_t"), e_t %>% as.character(), NA_character_),
      lbl = ifelse(!is.null(lbl), lbl %>% as.character(), NA_character_),
      proj = ifelse(!is.null(proj), proj %>% as.character(), NA_character_),
      info = ifelse(!is.null(info), info %>% as.character(), NA_character_))

  # Write to disk -----------------------------------------------------------

  if (write) {

    # Create the `ttt` dir in user's home if necessary
    ttt_dir_create()

    # The start date `s_d` is the reference date for CSV files generated;
    # if not provided use "2199-12-31"
    if (is.null(s) & !exists("s_d")) {
      file_name <- "2199-12-31.csv"
    } else if (!is.na(tbl_row$s_d)){
      file_name <- paste0(tbl_row$s_d, ".csv")
    }

    # If the file exists in the `ttt` dir, append row and sort by `s_d`;
    # otherwise, create a new file with a single row
    if (file_name %in% list.files(path = path.expand("~/Documents/.ttt/"))) {

      # Get the existing day info
      existing_day <-
        readr::read_csv(
          file = paste0(path.expand("~/Documents/.ttt/"), file_name),
          col_types = "cccccccc")

      previous_tt_n <- nrow(existing_day)

      # Bind new row to existing table
      updated_tt <-
        dplyr::bind_rows(
          existing_day, tbl_row) %>%
        dplyr::arrange(s_d, s_t)

      # Write revised table to `ttt` dir
      updated_tt %>%
        readr::write_csv(
          path = paste0(path.expand("~/Documents/.ttt/"), file_name))

      message(paste0("tt added, total tt: ", previous_tt_n + 1))

      ttt_print_record(tbl_row)

    } else {

      updated_tt <- tbl_row

      updated_tt %>%
        readr::write_csv(
          path = paste0(path.expand("~/Documents/.ttt/"), file_name))

      message("first tt of day added")

      ttt_print_record(tbl_row)
    }

  } else {

    ttt_print_record(tbl_row)
  }
}
