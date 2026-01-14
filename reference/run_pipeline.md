# Perform the entire feature transformation process

Reads in data and feature specifications and performs the requisite
transformations. Please see the package vignettes for more detailed
information on the JSON specification of features.

## Usage

``` r
run_pipeline(
  data_sources,
  feature_filenames = NULL,
  response_filenames = NULL,
  all_ids = NULL
)
```

## Arguments

- data_sources:

  A list, whose names are the unique identifiers of the data sources,
  and whose values are either the data frame itself or the file path
  from which they should be read from. Only CSV files are supported at
  this point in time.

- feature_filenames:

  A vector of file paths to the feature JSON specifications. Defaults to
  `NULL`.

- response_filenames:

  A vector of file paths to the response JSON specifications. Defaults
  to `NULL`.

- all_ids:

  A vector of all the unique numeric identifiers that should be in the
  final feature table. If not given, this will be determined by taking
  the union of all unique identifiers found in input tables used by at
  least one feature.

## Value

A list with the following elementss:

- `features`: A data frame with all the features. The first column is
  the ID column, and always has the name `id`. Subsequent columns are
  the features, with column names as specified in the
  `output_feature_name` field of the JSON files.

- `responses`: A data frame with all the responses. The structure is the
  same as the `features` data frame.

## Examples

``` r
run_pipeline(
  data_sources = list(ae = eider_example("random_ae_data.csv")),
  feature_filenames = eider_example("ae_total_attendances.json")
)
#> $features
#>    id total_ae_attendances
#> 1   0                    6
#> 2   1                    4
#> 3   2                    6
#> 4   3                    3
#> 5   4                    5
#> 6   5                    4
#> 7   6                    6
#> 8   7                    5
#> 9   8                    5
#> 10  9                   10
#> 11 10                    4
#> 12 11                    5
#> 13 12                    4
#> 14 13                    8
#> 15 14                    4
#> 16 15                    7
#> 17 16                    3
#> 18 17                    5
#> 19 18                    4
#> 20 19                    2
#> 
#> $responses
#>    id
#> 1   0
#> 2   1
#> 3   2
#> 4   3
#> 5   4
#> 6   5
#> 7   6
#> 8   7
#> 9   8
#> 10  9
#> 11 10
#> 12 11
#> 13 12
#> 14 13
#> 15 14
#> 16 15
#> 17 16
#> 18 17
#> 19 18
#> 20 19
#> 
```
