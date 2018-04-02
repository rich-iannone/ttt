
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis build
status](https://travis-ci.org/rich-iannone/ttt.svg?branch=master)](https://travis-ci.org/rich-iannone/ttt)

# Time Tracking Tool

Track the time taken to perform tasks with an input interface that is
fast and easy to use. We can add useful information alongside the task–a
label, a project identifier, info text–so that we have just enough
metadata. You can use a variety of shorthand input methods for quickly
defining dates and times (e.g., `yesterday at 2pm`, `2d ago at 18:30`,
etc.).

Tracked time events are stored on disk in a convenient location so that
we don’t have to explicitly manage the storage of tracked tasks.
Functions are available for inspecting the tracked tasks, returning
tibble objects. The stored data is easy to reason about and it’s human
readable: plain ol’ CSV files, one for each date where there are tracked
events.

**ttt**’s thinking: the troublesome task of tracking times takes *troppo
tempo*; the treatment? take, in total, the tiniest tidbit (a tincture,
truthfully) of time to tabularize those temporal *travails*.

## Adding Tracked Tasks

We can work with the following elements of a task:

  - `task (t)`: the task description
  - `start (s)`: the starting date and time (in `YYYY-MM-DD HH:MM`)
  - `end (e)`: the ending date and time (in `YYYY-MM-DD HH:MM`)
  - `label (l)`: an optional label to file the task under
  - `project (p)`: an optional project name/code for additional
    categorization
  - `info (i)`: an optional information note

Supppose we would like to track the following task:

| `element` | `content`                              |
| --------- | -------------------------------------- |
| `task:`   | `"Preparing presentation for Meetup"`  |
| `start:`  | `"2018-03-25 10:30"`                   |
| `end:`    | `"2018-03-25 14:20"`                   |
| `label`   | `"presentation"`                       |
| `project` | `"Meetup-2018-03-28"`                  |
| `info`    | `"Working on the introduction slides"` |

We can either use the `ttd()` function for drafting a tracked task (it
prints out a formatted tracked task entry in the console), or, the
`tt()` function which takes the tracked task information and commits it
to disk (still echoing the entry to the console).

Let’s make a time-tracking entry using the arguments of the `ttd()`
function:

``` r
ttd(
   task = "Preparing presentation for Meetup",
      s = "2018-03-25 10:30",
      e = "2018-03-25 14:20",
    lbl = "presentation",
   proj = "Meetup-2018-03-28",
   info = "Working on the introduction slides")
```

The following appears in the console to let us confirm this is correct.
Repeating the same call with `tt()` will commit the entry to disk.

    tracked task entry
    ------------------
    t:  Preparing presentation for Meetup
    s:  2018-03-25 10:30
    e:  2018-03-25 14:20
    l:  presentation
    p:  Meetup-2018-03-28
    i:  Working on the introduction slides

We can also use a simple shorthand for the same time-tracking entry.
Here we use a single string with single-letter element identifiers and
colons (e.g., `t:` for `task`, `p:` for `proj`). Each of these fields
are separated by a semicolon. Linebreaks are allowed and they are useful
for data entry. This yields the same console output:

``` r
ttd("
t: Preparing presentation for Meetup;
s: 2018-03-25 10:30; e: 2018-03-25 14:20;
l: presentation; p: Meetup-2018-03-28;
i: Working on the introduction slides
")
```

We can use all sorts of time shortcuts. For instance, if today is
`2018-03-25`, we can write the following for the `s:` and `e:` sections
and expect the same entry:

``` r
ttd("
t: Preparing presentation for Meetup;
s: 10:30a; e: 2:20p;
l: presentation; p: Meetup-2018-03-28;
i: Working on the introduction slides
")
```

Using times without dates assumes that the tracked time is for the
present day. When not using AM/PM markers (these can be `a`, `am`, `p`,
`pm`, and their capitalized forms), it is assumed that 24 hour time is
being used.

We can also use keywords such as `now` to insert the present date/time.
Events from days past can be logged using `yesterday at [time]` or `[n]d
ago at [time]`. Thus, a construction like `yesterday at 3:00p` is useful
for tracking tasks that began yesterday. Even something like `today
at 10:20am` will be interpreted the same as just using `10:20am`. Here’s
an example of this (written on `2018-03-26`):

``` r
ttd(
"t: Preparing presentation for Meetup;
s: yesterday at 10:30a; e: yesterday at 2:20p;
l: presentation; p: Meetup-2018-03-28;
i: Working on the introduction slides
")
```

    tracked task entry
    ------------------
    t:  Preparing presentation for Meetup
    s:  2018-03-25 10:30
    e:  2018-03-25 14:20
    l:  presentation
    p:  Meetup-2018-03-28
    i:  Working on the introduction slides

When the draft entry looks satisfactory, re-run the same statement using
`tt()` instead of `ttd()`. You’ll receive the same print message in the
console along with a message stating that the tracked task was added.

``` {r
tt(
"t: Preparing presentation for Meetup;
s: yesterday at 10:30a; e: yesterday at 2:20p;
l: presentation; p: Meetup-2018-03-28;
i: Working on the introduction slides
")
```

    first tt of day added
    tracked task entry
    ------------------
    t:  Preparing presentation for Meetup
    s:  2018-03-25 10:30
    e:  2018-03-25 14:20
    l:  presentation
    p:  Meetup-2018-03-28
    i:  Working on the introduction slides

## Reading Tracked Tasks from Disk

Getting all the tracked tasks as a tibble can be done with the
`get_tt()` function:

``` r
get_tt()
```

    # A tibble: 1 x 8
      task                              s_d        s_t   e_d        e_t   lbl          proj   info   
      <chr>                             <chr>      <chr> <chr>      <chr> <chr>        <chr>  <chr>  
    1 Preparing presentation for Meetup 2018-03-31 10:30 2018-03-31 14:20 presentation Meetu… Workin…

We can narrow down the records returned by either using the `s` (start)
or `e` (end) arguments of the `get_tt()` function (both accept
ISO-formatted dates), or, by using **dplyr**’s `filter()` function
afterward.

Records are written to disk (one CSV file per day, naming format is
`[YYYY-MM-DD].csv`. Files are created and modified in the hidden `.ttt`
folder of the user’s documents folder. The package will generate that
folder when necessary.

A few functions are provided to help with manage the files that *ttt*
creates:

  - `where_ttt_dir()`: provides the file path of the `.ttt` dir
  - `show_ttt_files()`: returns a vector of filenames produced though
    use of `tt()`
  - `delete_all_ttt_files()`: deletes all files in the `.ttt` directory

## Installation

You can install the development version of **ttt** from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rich-iannone/ttt")
```

If you encounter a bug, have usage questions, or want to share ideas to
make this package better, feel free to file an
[issue](https://github.com/rich-iannone/ttt/issues).

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## License

MIT © Richard Iannone
