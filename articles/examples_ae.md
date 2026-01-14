# Examples: A&E data

``` r
library(eider)
library(magrittr)
```

This series of vignettes in the *Gallery* section aim to demonstrate the
functionality of `eider` through examples that are similar to real-life
usage. To do this, we have created a series of randomly generated
datasets that are stored with the package. You can access these datasets
using the
[`eider_example()`](https://alan-turing-institute.github.io/eider/docs/reference/eider_example.md)
function, which will return the path to where the dataset is stored in
your installation of R.

``` r
ae_data_filepath <- eider_example("random_ae_data.csv")

ae_data_filepath
#> [1] "/tmp/RtmpiKfwzZ/temp_libpath357d1cc17fe3/eider/extdata/random_ae_data.csv"
```

## The data

In this specific vignette, we are using simulated [accident and
emergency (A&E)
data](https://publichealthscotland.scot/publications/ae-data-mart-user-guide/).
Our dataset does not contain every column specified in here, but serves
as a useful example of how real-life data may be treated using `eider`.

``` r
ae_data <- utils::read.csv(ae_data_filepath) |>
  dplyr::mutate(date = as.Date(date))

dplyr::glimpse(ae_data)
#> Rows: 100
#> Columns: 6
#> $ id                  <int> 15, 1, 18, 1, 11, 11, 17, 15, 9, 14, 3, 13, 13, 15…
#> $ date                <date> 2016-03-07, 2016-09-06, 2015-10-23, 2016-02-23, 2…
#> $ attendance_category <int> 5, 5, 5, 4, 2, 3, 3, 5, 4, 4, 5, 3, 5, 2, 5, 1, 1,…
#> $ diagnosis_1         <int> 7, 5, 6, 16, 15, 8, 16, 0, 18, 14, 14, 12, 1, 8, 0…
#> $ diagnosis_2         <int> 19, NA, NA, 2, 6, 5, 18, 12, 3, NA, NA, NA, 3, 9, …
#> $ diagnosis_3         <int> 18, NA, NA, NA, 99, NA, 12, 15, 15, NA, NA, NA, NA…
```

(Note that when the data is loaded by `eider`, the date columns are
automatically converted to the date type for you: you do not need to do
the manual processing above.)

This simplified table has 6 columns:

- `id`, which is a numeric patient ID;
- `date`, when the admission occurred;
- `attendance_category`, a numeric value indicating [the context for the
  patient’s
  admission](https://publichealthscotland.scot/services/national-data-catalogue/data-dictionary/a-to-z-of-data-dictionary-terms/attendance-category-ae/);
- `diagnosis_1`, `diagnosis_2`, and `diagnosis_3`, which are numeric
  values indicating [the patient’s
  diagnoses](https://publichealthscotland.scot/services/national-data-catalogue/data-dictionary/a-to-z-of-data-dictionary-terms/diagnosis-ae/).
  Note that `diagnosis_2` and `diagnosis_3` may not necessarily exist
  for every entry.

## Feature 1: Total number of attendances

As a first example, we will calculate the total number of attendances
for each patient. This feature may be specified in JSON as follows:

``` r
ae_count_filepath <- eider_example("ae_total_attendances.json")
writeLines(readLines(ae_count_filepath))
#> {
#>   "source_table": "ae",
#>   "transformation_type": "count",
#>   "grouping_column": "id",
#>   "absent_default_value": 0,
#>   "output_feature_name": "total_ae_attendances"
#> }
```

This JSON file is also provided as part of the package, and as with the
data, can be accessed using the
[`eider_example()`](https://alan-turing-institute.github.io/eider/docs/reference/eider_example.md)
function. It contains the following information:

- `source_table` specifies the identifier by which the input table is
  provided to `eider`;
- `output_feature_name` specifies the name of the column that will be
  created in the output table;
- `absent_default_value` specifies the value that will be used when a
  patient does not appear in the table. In this case, the logical value
  to use is 0: if a patient does not appear in the A&E table, it means
  they have 0 attendances.
- `grouping_column` specifies the column by which the table will be
  grouped. In this case, it is the `id` column.
- `transformation_type` specifies the way in which the feature is
  calculated. Here, a value of `"count"` means that the number of rows
  for each `id` will simply be counted.

This is one of the simplest possible features that can be calculated
using `eider`. It can be run using the
[`run_pipeline()`](https://alan-turing-institute.github.io/eider/docs/reference/run_pipeline.md)
function:

``` r
res <- run_pipeline(
  data_sources = list(ae = ae_data_filepath),
  feature_filenames = ae_count_filepath
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 2
#> $ id                   <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,…
#> $ total_ae_attendances <int> 6, 4, 6, 3, 5, 4, 6, 5, 5, 10, 4, 5, 4, 8, 4, 7, …
```

As described in the [introductory
vignette](https://alan-turing-institute.github.io/eider/docs/articles/eider.md),
the
[`run_pipeline()`](https://alan-turing-institute.github.io/eider/docs/reference/run_pipeline.md)
function returns both *features* and *responses*. In this case, because
we provided `ae_count_filepath` as one of the `feature_filenames`, the
data we are interested in is returned as part of `res$features`.

Notice also how the `data_sources` argument takes a named list. The
names of this list are used to match the `source_table` in the JSON file
to the actual data. In this case, because the `source_table` is `"ae"`,
we need to specify the data to be used as `ae = ae_data_filepath`.

## Feature 2: Total number of neurology attendances in 2017

As a second example, we will calculate the total number of attendances
for each patient for which:

- the date is within 2017; and
- they have a diagnosis pertaining to neurology (which corresponds to a
  diagnosis code of 13).

As before, this feature is still a `"count"` transformation. However, we
must additionally apply a filter to the the table before performing the
count, to ensure that only the rows we are interested in are counted
(see [the filtering
vignette](https://alan-turing-institute.github.io/eider/docs/articles/filtering.md)
for more examples of this).

### The date

In this filter, we want to constrain the date to be between 1 January
2017 and 31 December 2017. There is no specific filter for a date range;
however, we can construct this as the
[conjunction](https://en.wikipedia.org/wiki/Logical_conjunction) of two
subfilters: one which restricts the date to be on or after 1 January
2017, and one which restricts it to be on or before 31 December 2017.
Both of these filters must be simultaneously satisfied; thus, we need to
use an `"and"` filter:

``` json
{
    ...,
    "filter": {
        "type": "and",
        "subfilter": {
            "date1": {
                "column": "date",
                "type": "date_gt_eq",
                "value": "2017-01-01"
            },
            "date2": {
                "column": "date",
                "type": "date_lt_eq",
                "value": "2017-12-31"
            }
        }
    }
}
```

Note that the names for the subfilters—`"date1"` and `"date2"`—are
arbitrary; they are just used to distinguish between the two subfilters.
You can choose any names you consider useful.

### The diagnosis

Because the numeric diagnosis can occur in any of the three diagnosis
columns, we need to check all three and retain any rows where any of the
three diagnosis columns are equal to 13.

This is accomplished with an `"or"` filter:

``` json
{
    ...,
    "filter": {
        "type": "or",
        "subfilter": {
            "diag1": {
                "column": "diagnosis_1",
                "type": "in",
                "value": [13]
            },
            "diag2": {
                "column": "diagnosis_2",
                "type": "in",
                "value": [13]
            },
            "diag3": {
                "column": "diagnosis_3",
                "type": "in",
                "value": [13]
            }
        }
    }
}
```

### Combining both filters

To combine both filters, we can nest both of these within an `"and"`
filter.

``` json
{
    ...,
    "filter": {
        "type": "and",
        "subfilter": {
            "date": {
                "type": "and",
                "subfilter": {
                    "date1": {
                        "column": "date",
                        "type": "date_gt_eq",
                        "value": "2017-01-01"
                    },
                    "date2": {
                        "column": "date",
                        "type": "date_lt_eq",
                        "value": "2017-12-31"
                    }
                }
            },
            "diag": {
                "type": "or",
                "subfilter": {
                      "diag1": {
                          "column": "diagnosis_1",
                          "type": "in",
                          "value": [13]
                      },
                      "diag2": {
                          "column": "diagnosis_2",
                          "type": "in",
                          "value": [13]
                      },
                      "diag3": {
                          "column": "diagnosis_3",
                          "type": "in",
                          "value": [13]
                      }
                }
            }
        }
    }
}
```

Note that this can in principle be simplified, because

    (date1 AND date2) AND (diag1 OR diag2 OR diag3)

is really the same as

    date1 AND date2 AND (diag1 OR diag2 OR diag3)

and so we do not really need to nest the filters so deeply. However, the
above will work correctly, so we will keep it as it is.

### The feature

The JSON file for this feature is again provided as part of the package.
It is exactly the same as the earlier example, except that the filter
above has been added in.

``` r
ae_neurology_filepath <- eider_example("ae_attendances_neurology_2017.json")
writeLines(readLines(ae_neurology_filepath))
#> {
#>   "source_table": "ae",
#>   "transformation_type": "count",
#>   "grouping_column": "id",
#>   "absent_default_value": 0,
#>   "output_feature_name": "total_neurology_ae_attendances",
#>   "filter": {
#>     "type": "and",
#>     "subfilter": {
#>       "date": {
#>         "type": "and",
#>         "subfilter": {
#>           "date1": {
#>             "column": "date",
#>             "type": "date_gt_eq",
#>             "value": "2017-01-01"
#>           },
#>           "date2": {
#>             "column": "date",
#>             "type": "date_lt_eq",
#>             "value": "2017-12-31"
#>           }
#>         }
#>       },
#>       "diag": {
#>         "type": "or",
#>         "subfilter": {
#>           "diag1": {
#>             "column": "diagnosis_1",
#>             "type": "in",
#>             "value": [
#>               13
#>             ]
#>           },
#>           "diag2": {
#>             "column": "diagnosis_2",
#>             "type": "in",
#>             "value": [
#>               13
#>             ]
#>           },
#>           "diag3": {
#>             "column": "diagnosis_3",
#>             "type": "in",
#>             "value": [
#>               13
#>             ]
#>           }
#>         }
#>       }
#>     }
#>   }
#> }
```

This feature can be run in the same way as the previous one. To make
things slightly more interesting, we will provide both features to
[`run_pipeline()`](https://alan-turing-institute.github.io/eider/docs/reference/run_pipeline.md)
at the same time:

``` r
res <- run_pipeline(
  data_sources = list(ae = ae_data_filepath),
  feature_filenames = c(ae_count_filepath, ae_neurology_filepath)
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 3
#> $ id                             <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1…
#> $ total_ae_attendances           <int> 6, 4, 6, 3, 5, 4, 6, 5, 5, 10, 4, 5, 4,…
#> $ total_neurology_ae_attendances <int> 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, …
```

In this case, we can see that patient 0 (for example) has had 9 total
attendances, but only 1 of these were in 2017 and resulted in a
neurology diagnosis.

## Checking the results (so far)

We can verify some of the results above using a standard `dplyr`
pipeline. For feature 1:

``` r
ae_data |>
  dplyr::group_by(id) |>
  dplyr::summarise(total_ae_attendances = dplyr::n()) |>
  dplyr::glimpse()
#> Rows: 20
#> Columns: 2
#> $ id                   <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,…
#> $ total_ae_attendances <int> 6, 4, 6, 3, 5, 4, 6, 5, 5, 10, 4, 5, 4, 8, 4, 7, …
```

and for feature 2:

``` r
ae_data |>
  dplyr::filter(date >= "2017-01-01", date <= "2017-12-31") |>
  dplyr::filter(diagnosis_1 == 13 | diagnosis_2 == 13 | diagnosis_3 == 13) |>
  dplyr::group_by(id) |>
  dplyr::summarise(total_neurology_ae_attendances = dplyr::n()) |>
  dplyr::glimpse()
#> Rows: 2
#> Columns: 2
#> $ id                             <int> 2, 6
#> $ total_neurology_ae_attendances <int> 1, 1
```

This tells us that patients 0 and 2 are the only ones with any neurology
attendances in 2017, and is consistent with the feature table that
`eider` has calculated. However, notice that `eider` has taken care of
joining the features together and inserting the missing value of 0 where
necessary. Using `eider` also helps to avoid errors that can easily
creep in when data is mutated in a long script.

## Feature 3: Whether a patient has ever attended A&E

Through a slight modification of the first feature, we can also
calculate whether a patient has ever attended A&E. This is a binary
feature, which has values of either 1 (if the patient has attended A&E)
or 0 (if they have not). All we need to do is to replace the
`transformation_type` with `"present"` (instead of `"count"`):

``` r
ae_present_filepath <- eider_example("has_visited_ae.json")
writeLines(readLines(ae_present_filepath))
#> {
#>   "source_table": "ae",
#>   "transformation_type": "present",
#>   "grouping_column": "id",
#>   "output_feature_name": "has_visited_ae"
#> }
```

``` r
res <- run_pipeline(
  data_sources = list(ae = ae_data_filepath),
  feature_filenames = ae_present_filepath
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 2
#> $ id             <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1…
#> $ has_visited_ae <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
```

## Feature 4: The number of days since the last A&E attendance

As an example of a completely different transformation type, we look at
the `"time_since"` feature type here. As the name suggests, this
calculates the time since an event: in this case, we specify
“from_first”: “false”`and`“cutoff_date”: “2021-03-25” to calculate the
time since the last event up to 25 March 2021; and
`"time_units": "days"` to return the value in days. The `"date_column"`
specifies the name of the column in the input table which contains the
date of attendance.

The default value for patients who do not appear in this dataset should,
logically, be set to something large, to indicate that they have not had
a recent A&E attendance. In this case we use 2000.

``` r
days_since_ae_filepath <- eider_example("days_since_last_ae.json")
writeLines(readLines(days_since_ae_filepath))
#> {
#>   "source_table": "ae",
#>   "grouping_column": "id",
#>   "transformation_type": "time_since",
#>   "time_units": "days",
#>   "from_first": false,
#>   "output_feature_name": "days_since_last_ae_visit",
#>   "date_column": "date",
#>   "cutoff_date": "2021-03-25",
#>   "absent_default_value": 2000
#> }
```

``` r
res <- run_pipeline(
  data_sources = list(ae = ae_data_filepath),
  feature_filenames = days_since_ae_filepath
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 2
#> $ id                       <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,…
#> $ days_since_last_ae_visit <dbl> 1344, 1661, 1223, 1428, 1569, 1349, 1220, 125…
```
