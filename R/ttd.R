#' Draft a Tracked Task
#'
#' Use the syntax of the \code{tt()} function without
#' actually committing the task. This is useful for
#' practicing the shorthand of entering a tracked task
#' since the tracked-time event is echoed to the console.
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
#' @export
ttd <- function(...,
                task = NULL,
                s = NULL,
                e = NULL,
                lbl = NULL,
                proj = NULL,
                info = NULL) {

  tt(... = ...,
     task = task,
     s = s,
     e = e,
     lbl = lbl,
     proj = proj,
     info = info,
     write = FALSE)
}
