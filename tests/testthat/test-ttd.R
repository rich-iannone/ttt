context("Create a tracked time entry")

test_that("Creating a tracked time draft entry is possible", {

  # Capture output text emitted to console
  captured_output <-
    capture_output_lines(
      ttd(
        task = "Task for testthat",
        s = "2018-03-28 10:30",
        e = "2018-03-28 10:40",
        lbl = "testthat",
        proj = "Testing-ttt",
        info = "Draft tt entry"))

  # Expect certain lines to appear in the captured output
  expect_equal(
    captured_output[1],
    "tracked task entry")

  expect_equal(
    captured_output[2],
    "------------------")

  expect_equal(
    captured_output[3],
    "t:  Task for testthat")

  expect_equal(
    captured_output[4],
    "s:  2018-03-28 10:30")

  expect_equal(
    captured_output[5],
    "e:  2018-03-28 10:40")

  expect_equal(
    captured_output[6],
    "l:  testthat")

  expect_equal(
    captured_output[7],
    "p:  Testing-ttt")

  expect_equal(
    captured_output[8],
    "i:  Draft tt entry")
})
