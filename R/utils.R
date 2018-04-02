
ttt_dir_create <- function() {

  # Check for the existence of the `ttt_dir`
  if (dir.exists(path.expand("~/Documents/.ttt/")) == FALSE) {

    # Create the directory if it does not exist
    dir.create(path = path.expand("~/Documents/.ttt/"), recursive = TRUE)

    # Issue a message about the creation of the directory
    message(
      paste0(
        "The `.ttt` directory has been generated at ",
        where_ttt_dir()))
  }
}

ttt_dir_files <- function() {

  # Check for the existence of the `ttt_dir`
  if (dir.exists(path.expand("~/Documents/.ttt/"))) {

    # Create the directory if it does not exist
    list.files(path = path.expand("~/Documents/.ttt/"))
  } else {
    return("Path does not exist.")
  }
}

ttt_print_record <- function(tbl_row, title = NULL) {

  if (is.null(title)) {
    title <- "tracked task entry"
  }

  cat(
    paste0(
      title, "\n",
      "------------------\n",
      "t:  ", tbl_row[1]$task[1], "\n",
      "s:  ", tbl_row[2]$s_d[1], " ", tbl_row[3]$s_t, "\n",
      "e:  ", tbl_row[4]$e_d[1], " ", tbl_row[5]$e_t, "\n",
      "l:  ", tbl_row[6]$lbl[1], "\n",
      "p:  ", tbl_row[7]$proj[1], "\n",
      "i:  ", tbl_row[8]$info[1], "\n"))
}
