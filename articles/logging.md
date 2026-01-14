# Logging and errors

``` r
library(eider)
```

## Logging in `eider`

`eider` uses [the `logger`
package](https://daroczig.github.io/logger/index.html) to log messages.
Most messages in `eider` are logged at either the `DEBUG` level (when
`eider` is e.g. parsing information from JSON), or at the `TRACE` level
(most functions in `eider` log a `TRACE` message containing the
execution context).

When running a pipeline, you can set the logging level with either:

``` r
logger::log_threshold(logger::DEBUG)
```

which causes the `DEBUG` messages to be displayed, or:

``` r
logger::log_threshold(logger::TRACE)
```

which causes both the `TRACE` and `DEBUG` messages to be displayed.

## Errors with context

Additionally, the execution context (which is usually restricted to
`TRACE` messages) is also displayed when `eider` runs into an error. If
you run into an error that does not provide enough information, please
consider [submitting an
issue](https://github.com/alan-turing-institute/eider/issues).

Here are a few examples:

### Wrong transformation type

    {
      "source_table": "ae2",
      "transformation_type": "COUNT DRACULA",
      "grouping_column": "id",
      "output_feature_name": "something"
    }

In the JSON above
([`json_examples/logging1.json`](https://github.com/alan-turing-institute/eider/blob/main/vignettes/json_examples/logging1.json)),
an invalid `transformation_type` is specified. Notice how the resulting
error tells you which JSON file the error occurs in.

``` r
run_pipeline(
  data_sources = list(ae2 = eider_example("random_ae_data.csv")),
  feature_filenames = "json_examples/logging1.json"
)
#> Error:
#> ! Unknown transformation type: count dracula
#> Context:
#>  > featurise: json_examples/logging1.json
```

### Wrong column name

    {
      "source_table": "ae2",
      "transformation_type": "COUNT",
      "grouping_column": "this_column_doesnt_exist",
      "output_feature_name": "something"
    }

Here
([`json_examples/logging2.json`](https://github.com/alan-turing-institute/eider/blob/main/vignettes/json_examples/logging2.json)),
a `grouping_column` is specified, but such a column does not exist in
the input table.

``` r
run_pipeline(
  data_sources = list(ae2 = eider_example("random_ae_data.csv")),
  feature_filenames = "json_examples/logging2.json"
)
#> Error:
#> ! The column 'this_column_doesnt_exist' supplied for 'grouping_column' was not found in the input table.
#> Context:
#>  > featurise: json_examples/logging2.json
#>  > featurise_count
```

### Data type mismatch

    {
      "source_table": "ae2",
      "transformation_type": "COUNT",
      "grouping_column": "id",
      "output_feature_name": "something",
      "filter": {
        "column": "diagnosis_1",
        "type": "in",
        "value": "a string"
      }
    }

This example
([`json_examples/logging3.json`](https://github.com/alan-turing-institute/eider/blob/main/vignettes/json_examples/logging3.json))
specifies that the table should be filtered to only retain rows where
`diagnosis_1` is equal to `"a string"`, but in the actual table,
`diagnosis_1` is an integer.

``` r
run_pipeline(
  data_sources = list(ae2 = eider_example("random_ae_data.csv")),
  feature_filenames = "json_examples/logging3.json"
)
#> Error:
#> ! The 'value' field of a filter object must be of the same type as the column to be filtered on. However, the column 'diagnosis_1' is of type 'integer', while the value given is of type 'character'.
#> Context:
#>  > featurise: json_examples/logging3.json
#>  > featurise_count
#>  > filter_basic
```
