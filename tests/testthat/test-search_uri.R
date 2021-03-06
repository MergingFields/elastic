context("search_uri")

x <- connect(warn = FALSE)
load_shakespeare(x)
Sys.sleep(1)

test_that("basic search_uri works", {
  a <- Search_uri(x, index="shakespeare")
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  expect_equal(names(a$hits$hits[[1]]), c('_index','_type','_id','_score','_source'))
})

test_that("search for document type works", {
  b <- Search_uri(x, index="shakespeare", type="line")
  if (x$es_ver() < 700) {
    expect_match(vapply(b$hits$hits, "[[", "", "_type"), "line")
  } else {
    expect_equal(vapply(b$hits$hits, "[[", "", "_type"), character(0))
  }
})

test_that("search for specific fields works", {

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    c <- Search_uri(x, index = "shakespeare", source = c('play_name','speaker'))
    expect_equal(sort(unique(lapply(c$hits$hits, function(x) names(x$`_source`)))[[1]]), c('play_name','speaker'))
  } else {
    c <- Search_uri(x, index = "shakespeare", fields = c('play_name','speaker'))
    expect_equal(sort(unique(lapply(c$hits$hits, function(x) names(x$fields)))[[1]]), c('play_name','speaker'))
  }
})

test_that("search paging works", {

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    d <- Search_uri(x, index="shakespeare", size=1, source = 'text_entry')$hits$hits
  } else {
    d <- Search_uri(x, index="shakespeare", size=1, fields='text_entry')$hits$hits
  }
  expect_equal(length(d), 1)
})

test_that("search terminate_after parameter works", {

  e <- Search_uri(x, index="shakespeare", terminate_after=1)
  expect_is(e$hits, "list")
})

test_that("getting json data back from search works", {

  suppressMessages(require('jsonlite'))
  f <- Search_uri(x, index="shakespeare", type="line", raw=TRUE)
  expect_is(f, "character")
  expect_true(jsonlite::validate(f))
  expect_is(jsonlite::fromJSON(f), "list")
})
