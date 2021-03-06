context("Search_template")

x <- connect(warn = FALSE)
load_shakespeare(x)

body1 <- '{
   "inline" : {
     "query": { "match" : { "{{my_field}}" : "{{my_value}}" } },
     "size" : "{{my_size}}"
   },
   "params" : {
     "my_field" : "Species",
     "my_value" : "setosa",
     "my_size" : 3
   }
}'

body2 <- '{
 "inline": {
   "query": {
      "match": {
          "Species": "{{query_string}}"
      }
   }
 },
 "params": {
   "query_string": "versicolor"
 }
}'

if (x$es_ver() >= 560) {
  body1 <- sub("inline", "source", body1)
  body2 <- sub("inline", "source", body2)
}

iris2 <- stats::setNames(iris, gsub("\\.", "_", names(iris)))

test_that("basic Search_template works", {
  if (x$es_ver() < 200) skip('feature not in this ES version')
  
  if (index_exists(x, "iris")) invisible(suppressMessages(index_delete(x, "iris")))
  if (x$es_ver() < 700) {
    invisible(docs_bulk(x, iris2, "iris", type = "iris", quiet = TRUE))
  } else {
    invisible(docs_bulk(x, iris2, "iris", quiet = TRUE))
  }
  Sys.sleep(2)

  a <- Search_template(x, body = body1)
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  # expect_equal(
  #   unique(vapply(a$hits$hits, "[[", "", c('_source', 'Species'))),
  #   "setosa"
  # )
  # expect_equal(length(a$hits$hits), 3)
})

test_that("Search_template - raw parameter works", {
  if (x$es_ver() < 200) skip('feature not in this ES version')
  
  b <- Search_template(x, body = body1, raw = TRUE)
  expect_is(b, "character")
})

test_that("Search_template pre-registration works", {
  if (x$es_ver() < 200) skip('feature not in this ES version')
  
  if (!index_exists(x, "iris")) invisible(suppressMessages(index_delete(x, "iris")))
  if (x$es_ver() < 700) {
    invisible(docs_bulk(x, iris2, "iris", type = "iris", quiet = TRUE))
  } else {
    invisible(docs_bulk(x, iris2, "iris", quiet = TRUE))
  }

  if (x$es_ver() < 600) {
    if (x$es_ver() == 566) skip('Search_template_register not working in this ES version')
    a <- Search_template_register(x, 'foobar', body = body2)
    expect_is(a, "list")
    if (x$es_ver() >= 500) {
      expect_named(a, "acknowledged")
    } else {
      expect_equal(a$`_id`, "foobar")
    }
    
    b <- Search_template_get(x, 'foobar')
    expect_is(b, "list")
    expect_equal(b$`_id`, "foobar")
    # if (x$es_ver() >= 560) {
    #   expect_equal(b$lang, "mustache")
    #   expect_is(b$template, "character")
    # } else {
    #   expect_equal(b$script$lang, "mustache")
    # }
    
    c <- Search_template_delete(x, 'foobar')
    expect_is(c, "list")
    if (gsub("\\.", "", x$ping()$version$number) >= 500) {
      expect_named(c, "acknowledged")
    } else {
      expect_equal(c$`_id`, "foobar")
      expect_true(c$found)
    }
    expect_error(Search_template_get(x, "foobar"), 
                 "Not Found")
  }
})

test_that("Search_template validate (aka, render) works", {
  if (x$es_ver() < 200) skip('Search_template not in this ES version')
  
  a <- Search_template_render(x, body = body1)
  
  expect_is(a, "list")
  expect_equal(names(a), 'template_output')
  expect_is(a$template_output, "list")
  expect_equal(a$template_output$size, "3")
  expect_named(a$template_output$query, 'match')
  expect_named(a$template_output$query$match, 'Species')
  expect_equal(a$template_output$query$match$Species, 'setosa')
})

test_that("search_template fails as expected", {
  if (x$es_ver() < 200) skip('feature not in this ES version')
  
  if (x$es_ver() >= 500) {
    expect_error(Search_template(x, index = "shakespeare", body = list(a = 5)),
                 "\\[search_template\\] unknown field \\[a\\], parser not found")
  } else {
    expect_error(Search_template(x, index = "shakespeare", body = list(a = 5)),
                 "all shards failed") 
  }
  
  if (x$es_ver() >= 500) {
    expect_error(Search_template(x, body = 5))
  } else {
    expect_error(Search_template(x, body = 5), "all shards failed")
  }
  
  expect_error(Search_template(x, raw = 4), "'raw' parameter must be") 
})
