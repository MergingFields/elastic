context("mtermvectors")

invisible(connect())

body <- '{
       "ids" : ["AVXdx8Eqg_0Z_tpMDyP_", "AVXdx8Eqg_0Z_tpMDyQ1"],
       "parameters": {
           "fields": [
               "Plot"
           ],
           "term_statistics": true
       }
  }'

test_that("mtermvectors works", {
  aa <- mtermvectors('omdb', 'omdb', body = body)
  
  expect_is(aa, 'list')
  expect_named(aa, 'docs')
  
  expect_equal(aa$docs[[1]]$`_index`, "omdb")
  expect_equal(aa$docs[[1]]$`_type`, "omdb")
  expect_equal(aa$docs[[1]]$`_id`, "AVXdx8Eqg_0Z_tpMDyP_")
  
  expect_is(aa$docs[[1]]$term_vectors, "list")
  expect_named(aa$docs[[1]]$term_vectors, 'Plot')
  expect_named(aa$docs[[1]]$term_vectors$Plot, c('field_statistics', 'terms'))
  expect_is(aa$docs[[1]]$term_vectors$Plot$field_statistics, "list")
  expect_is(aa$docs[[1]]$term_vectors$Plot$terms, "list")
  expect_is(aa$docs[[1]]$term_vectors$Plot$terms[[1]], "list")
  expect_named(aa$docs[[1]]$term_vectors$Plot$terms[[1]]$tokens[[1]], c('position', 'start_offset', 'end_offset'))
  })

test_that("mtermvectors fails well", {
  expect_error(mtermvectors(body = body), "index is missing")
  expect_error(mtermvectors("omdb", body = body), "type is missing")
})