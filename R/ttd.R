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
#' @examples
#' # Draft a tracked task using `ttd()`; it won't
#' # be committed to the ttt_dir but information
#' # on the tracked task will be echoed back--this
#' # is useful for ensuring that the information
#' # is correct before using `tt()`
#' ttd(
#'   task = "Description of the task",
#'   s = "2018-05-24 11:30",
#'   e = "2018-05-24 12:00",
#'   lbl = "label",
#'   proj = "project_name",
#'   info = "Any additional information")
#'
#' # We can also use the shorthand notation
#' ttd("
#' t: Description of the task;
#' s: 2018-05-24 11:30;
#' e: 2018-05-24 12:00;
#' l: label;
#' p: project_name;
#' i: Any additional information
#' ")
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
