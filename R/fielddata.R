#' fielddata
#' 
#' Deep dive on fielddata details
#' 
#' @name fielddata
#' @details 
#' Most fields are indexed by default, which makes them searchable. Sorting, 
#' aggregations, and accessing field values in scripts, however, requires a 
#' different access pattern from search.
#' 
#' Text fields use a query-time in-memory data structure called fielddata. 
#' This data structure is built on demand the first time that a field is 
#' used for aggregations, sorting, or in a script. It is built by reading 
#' the entire inverted index for each segment from disk, inverting the 
#' term-document relationship, and storing the result in memory, in the 
#' JVM heap.
#' 
#' fielddata is disabled on text fields by default. Fielddata can consume a 
#' lot of heap space, especially when loading high cardinality text fields. 
#' Once fielddata has been loaded into the heap, it remains there for the 
#' lifetime of the segment. Also, loading fielddata is an expensive process 
#' which can cause users to experience latency hits. This is why fielddata 
#' is disabled by default. If you try to sort, aggregate, or access values 
#' from a script on a text field, you will see this exception:
#' 
#' "Fielddata is disabled on text fields by default. Set fielddata=true on 
#' `your_field_name` in order to load fielddata in memory by uninverting 
#' the inverted index. Note that this can however use significant memory."
#' 
#' To enable fielddata on a text field use the PUT mapping API, for example
#' \code{mapping_create("shakespeare", body = '{
#'   "properties": {
#'     "speaker": { 
#'       "type":     "text",
#'       "fielddata": true
#'     }
#'   }
#' }')}
#' 
#' You may get an error about \code{update_all_types}, in which case set
#' \code{update_all_types=TRUE} in \code{mapping_create}, e.g.,
#' 
#' \code{mapping_create("shakespeare", update_all_types=TRUE, body = '{
#'   "properties": {
#'     "speaker": { 
#'       "type":     "text",
#'       "fielddata": true
#'     }
#'   }
#' }')}
#' 
#' See \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/fielddata.html#_enabling_fielddata_on_literal_text_literal_fields}
#' for more information.
NULL
