% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Search_uri.R
\name{Search_uri}
\alias{Search_uri}
\title{Full text search of Elasticsearch with URI search}
\usage{
Search_uri(
  conn,
  index = NULL,
  type = NULL,
  q = NULL,
  df = NULL,
  analyzer = NULL,
  default_operator = NULL,
  explain = NULL,
  source = NULL,
  fields = NULL,
  sort = NULL,
  track_scores = NULL,
  timeout = NULL,
  terminate_after = NULL,
  from = NULL,
  size = NULL,
  search_type = NULL,
  lowercase_expanded_terms = NULL,
  analyze_wildcard = NULL,
  version = NULL,
  lenient = FALSE,
  raw = FALSE,
  asdf = FALSE,
  track_total_hits = TRUE,
  search_path = "_search",
  stream_opts = list(),
  ...
)
}
\arguments{
\item{conn}{an Elasticsearch connection object, see \code{\link{connect}}}

\item{index}{Index name, one or more}

\item{type}{Document type. Note that \code{type} is deprecated in
Elasticsearch v7 and greater, and removed in Elasticsearch v8. We will
strive to support types for folks using older ES versions}

\item{q}{The query string (maps to the query_string query, see Query String
Query for more details). See
https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
for documentation and examples.}

\item{df}{(character) The default field to use when no field prefix is
defined within the query.}

\item{analyzer}{(character) The analyzer name to be used when analyzing the
query string.}

\item{default_operator}{(character) The default operator to be used, can be
\code{AND} or \code{OR}. Default: \code{OR}}

\item{explain}{(logical) For each hit, contain an explanation of how
scoring of the hits was computed. Default: \code{FALSE}}

\item{source}{(logical) Set to \code{FALSE} to disable retrieval of the
\code{_source} field. You can also retrieve part of the document by
using \code{_source_include} & \code{_source_exclude} (see the \code{body}
documentation for more details). You can also include a comma-delimited
string of fields from the source document that you want back. See also
the \strong{fields} parameter}

\item{fields}{(character) The selective stored fields of the document to
return for each hit. Not specifying any value will cause no fields to return.
Note that in Elasticsearch v5 and greater, \strong{fields} parameter has
changed to \strong{stored_fields}, which is not on by default. You can
however, pass fields to \strong{source} parameter}

\item{sort}{(character) Sorting to perform. Can either be in the form of
fieldName, or \code{fieldName:asc}/\code{fieldName:desc}. The fieldName
can either be an actual field within the document, or the special
\code{_score} name to indicate sorting based on scores. There can be several
sort parameters (order is important).}

\item{track_scores}{(logical) When sorting, set to \code{TRUE} in order to
still track scores and return them as part of each hit.}

\item{timeout}{(numeric) A search timeout, bounding the search request to
be executed within the specified time value and bail with the hits
accumulated up to that point when expired. Default: no timeout.}

\item{terminate_after}{(numeric) The maximum number of documents to collect
for each shard, upon reaching which the query execution will terminate
early. If set, the response will have a boolean field terminated_early to
indicate whether the query execution has actually terminated_early.
Default: no terminate_after}

\item{from}{(character) The starting from index of the hits to return.
Pass in as a character string to avoid problems with large number
conversion to scientific notation. Default: 0}

\item{size}{(character) The number of hits to return. Pass in as a
character string to avoid problems with large number conversion to
scientific notation. Default: 10. The default maximum is 10,000 - however,
you can change this default maximum by changing the
\code{index.max_result_window} index level parameter.}

\item{search_type}{(character) The type of the search operation to perform.
Can be \code{query_then_fetch} (default) or \code{dfs_query_then_fetch}.
Types \code{scan} and \code{count} are deprecated.
See \url{http://bit.ly/19Am9xP} for more details on the different types of
search that can be performed.}

\item{lowercase_expanded_terms}{(logical) Should terms be automatically
lowercased or not. Default: \code{TRUE}.}

\item{analyze_wildcard}{(logical) Should wildcard and prefix queries be
analyzed or not. Default: \code{FALSE}.}

\item{version}{(logical) Print the document version with each document.}

\item{lenient}{(logical) If \code{TRUE} will cause format based failures (like
providing text to a numeric field) to be ignored. Default: \code{FALSE}}

\item{raw}{(logical) If \code{FALSE} (default), data is parsed to list.
If \code{TRUE}, then raw JSON returned}

\item{asdf}{(logical) If \code{TRUE}, use \code{\link[jsonlite]{fromJSON}}
to parse JSON directly to a data.frame. If \code{FALSE} (Default), list
output is given.}

\item{track_total_hits}{(logical, numeric) If \code{TRUE} will always track
the number of hits that match the query accurately. If \code{FALSE} will
count documents accurately up to 10000 documents. If \code{is.integer} will
count documents accurately up to the number. Default: \code{TRUE}}

\item{search_path}{(character) The path to use for searching. Default
to \verb{_search}, but in some cases you may already have that in the base
url set using \code{\link[=connect]{connect()}}, in which case you can set this
to \code{NULL}}

\item{stream_opts}{(list) A list of options passed to
\code{\link[jsonlite]{stream_out}} - Except that you can't pass \code{x} as
that's the data that's streamed out, and pass a file path instead of a
connection to \code{con}. \code{pagesize} param doesn't do much as
that's more or less controlled by paging with ES.}

\item{...}{Curl args passed on to \code{\link[crul]{verb-POST}}}
}
\description{
Full text search of Elasticsearch with URI search
}
\examples{
\dontrun{
# connection setup
(x <- connect())

# URI string queries
Search_uri(x, index="shakespeare")
## if you're using an older ES version, you may have types
if (gsub("\\\\.", "", x$ping()$version$number) < 700) {
Search_uri(x, index="shakespeare", type="act")
Search_uri(x, index="shakespeare", type="scene")
Search_uri(x, index="shakespeare", type="line")
}

## Return certain fields
if (gsub("\\\\.", "", ping()$version$number) < 500) {
  ### ES < v5
  Search_uri(x, index="shakespeare", fields=c('play_name','speaker'))
} else {
  ### ES > v5
  Search_uri(x, index="shakespeare", source=c('play_name','speaker'))
}

## Search many indices
Search_uri(x, index = "gbif")$hits$total$value
Search_uri(x, index = "shakespeare")$hits$total$value
Search_uri(x, index = c("gbif", "shakespeare"))$hits$total$value

## search_type
## NOTE: If you're in ES V5 or greater, see \code{?fielddata}
Search_uri(x, index="shakespeare", search_type = "query_then_fetch")
Search_uri(x, index="shakespeare", search_type = "dfs_query_then_fetch")
# Search_uri(x, index="shakespeare", search_type = "scan") # only when scrolling

## sorting
Search_uri(x, index="shakespeare", sort="text_entry")
if (gsub("\\\\.", "", x$ping()$version$number) < 500) {
  Search_uri(x, index="shakespeare", sort="speaker:desc", fields='speaker')
  Search_uri(x, index="shakespeare", sort=c("speaker:desc","play_name:asc"),
    fields=c('speaker','play_name'))
}

## pagination
Search_uri(x, index="shakespeare", size=1)$hits$hits
Search_uri(x, index="shakespeare", size=1, from=1)$hits$hits

## queries
### Search in all fields
Search_uri(x, index="shakespeare", q="york")

### Searchin specific fields
Search_uri(x, index="shakespeare", q="speaker:KING HENRY IV")$hits$total$value

### Exact phrase search by wrapping in quotes
Search_uri(x, index="shakespeare", q='speaker:"KING HENRY IV"')$hits$total$value

### can specify operators between multiple words parenthetically
Search_uri(x, index="shakespeare", q="speaker:(HENRY OR ARCHBISHOP)")$hits$total$value

### where the field line_number has no value (or is missing)
Search_uri(x, index="shakespeare", q="_missing_:line_number")$hits$total$value

### where the field line_number has any non-null value
Search_uri(x, index="shakespeare", q="_exists_:line_number")$hits$total$value

### wildcards, either * or ?
Search_uri(x, index="shakespeare", q="*ay")$hits$total$value
Search_uri(x, index="shakespeare", q="m?y")$hits$total$value

### regular expressions, wrapped in forward slashes
Search_uri(x, index="shakespeare", q="text_entry:/[a-z]/")$hits$total$value

### fuzziness
Search_uri(x, index="shakespeare", q="text_entry:ma~")$hits$total$value
Search_uri(x, index="shakespeare", q="text_entry:the~2")$hits$total$value
Search_uri(x, index="shakespeare", q="text_entry:the~1")$hits$total$value

### Proximity searches
Search_uri(x, index="shakespeare", q='text_entry:"as hath"~5')$hits$total$value
Search_uri(x, index="shakespeare", q='text_entry:"as hath"~10')$hits$total$value

### Ranges, here where line_id value is between 10 and 20
Search_uri(x, index="shakespeare", q="line_id:[10 TO 20]")$hits$total$value

### Grouping
Search_uri(x, index="shakespeare", q="(hath OR as) AND the")$hits$total$value

# Limit number of hits returned with the size parameter
Search_uri(x, index="shakespeare", size=1)

# Give explanation of search in result
Search_uri(x, index="shakespeare", size=1, explain=TRUE)

## terminate query after x documents found
## setting to 1 gives back one document for each shard
Search_uri(x, index="shakespeare", terminate_after=1)
## or set to other number
Search_uri(x, index="shakespeare", terminate_after=2)

## Get version number for each document
Search_uri(x, index="shakespeare", version=TRUE, size=2)

## Get raw data
Search_uri(x, index="shakespeare", raw=TRUE)

## Curl options
### verbose
out <- Search_uri(x, index="shakespeare", verbose = TRUE)
}
}
\seealso{
\code{\link[=fielddata]{fielddata()}}

\code{\link[=Search]{Search()}} \code{\link[=Search_template]{Search_template()}} \code{\link[=count]{count()}} \code{\link[=fielddata]{fielddata()}}
}
