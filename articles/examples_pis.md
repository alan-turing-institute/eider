# Examples: PIS data

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
pis_data_filepath <- eider_example("random_pis_data.csv")

pis_data_filepath
#> [1] "/tmp/RtmpiKfwzZ/temp_libpath357d1cc17fe3/eider/extdata/random_pis_data.csv"
```

## The data

In this specific vignette, we are using simulated [Prescribing
Information System
(PIS)](https://publichealthscotland.scot/services/national-data-catalogue/national-datasets/a-to-z-of-datasets/prescribing-information-system-pis/).
Our dataset does not contain every column specified in here, but serves
as a useful example of how real-life data may be treated using `eider`.

``` r
pis_data <- utils::read.csv(pis_data_filepath) |>
  dplyr::mutate(paid_date = lubridate::ymd(paid_date))

dplyr::glimpse(pis_data)
#> Rows: 100
#> Columns: 4
#> $ id          <int> 19, 19, 19, 7, 3, 18, 2, 5, 2, 6, 10, 2, 15, 4, 15, 6, 15,…
#> $ paid_date   <date> 2017-12-15, 2016-08-11, 2015-07-07, 2017-03-14, 2015-08-0…
#> $ bnf_section <int> 113, 106, 105, 112, 111, 106, 108, 104, 109, 110, 109, 115…
#> $ num_items   <int> 3, 5, 1, 1, 1, 3, 4, 3, 1, 4, 4, 5, 3, 5, 1, 2, 4, 2, 3, 1…
```

(Note that when the data is loaded by `eider`, the date columns are
automatically converted to the date type for you: you do not need to do
the manual processing above.)

This simplified table has 4 columns:

- `id`, which is a numeric patient ID;
- `paid_date`, which is the date the prescription was paid for;
- `bnf_section`, which is a code for the type of drug prescribed;
- `num_items`, which is the number of items prescribed.

## Feature 1: Number of unique prescription types

A simple example of a feature here is the number of unique prescription
type each patient has received, which corresponds to the number of
distinct values of `bnf_section` per `id`.

The JSON required uses the `nunique` transformation type, and we must
specify the column over which we want to take the distinct values using
`"aggregation_column": "bnf_section"`.

``` r
unique_bnf_filepath <- eider_example("distinct_bnf_prescriptions.json")
writeLines(readLines(unique_bnf_filepath))
#> {
#>   "source_table": "pis",
#>   "transformation_type": "nunique",
#>   "grouping_column": "id",
#>   "absent_default_value": 0,
#>   "aggregation_column": "bnf_section",
#>   "output_feature_name": "unique_bnf_sections"
#> }
```

``` r
res <- run_pipeline(
  data_sources = list(pis = pis_data_filepath),
  feature_filenames = unique_bnf_filepath
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 2
#> $ id                  <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, …
#> $ unique_bnf_sections <int> 3, 3, 4, 6, 2, 5, 3, 2, 5, 2, 4, 1, 4, 4, 3, 6, 3,…
```

## Feature 2: Number of drugs prescribed since 2016

A slightly more complicated example involves summing up the total number
of items prescribed, but only counting those transactions since 2016—in
other words, those where the `paid_date` is on or after 1 January 2016.

To do this, we perform a `sum` over the `num_items` column, and use a
filter to remove any rows that are prior to this date. The filter has
the type `"date_gt_eq"`, which means greater than or equal to.

``` r
drugs_since_2016_filepath <- eider_example("num_prescriptions_since_2016.json")
writeLines(readLines(drugs_since_2016_filepath))
#> {
#>   "source_table": "pis",
#>   "transformation_type": "sum",
#>   "grouping_column": "id",
#>   "absent_default_value": 0,
#>   "aggregation_column": "num_items",
#>   "output_feature_name": "num_prescriptions_since_2016",
#>   "filter": {
#>     "column": "paid_date",
#>     "type": "date_gt_eq",
#>     "value": "2016-01-01"
#>   }
#> }
```

``` r
res <- run_pipeline(
  data_sources = list(pis = pis_data_filepath),
  feature_filenames = drugs_since_2016_filepath
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 2
#> $ id                           <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,…
#> $ num_prescriptions_since_2016 <int> 10, 5, 19, 21, 5, 8, 12, 6, 8, 3, 4, 6, 7…
```

## Feature 3: Maximum number of items prescribed in a single transaction

As a warm-up to feature 4, we will write a small feature that looks up
the maximum value of `num_items` for each patient in the table. This is
a `max` transformation type, which is very similar to the `nunique` and
`sum` that we have seen above, except that we run a different
aggregation function on the `num_items` column: instead of counting the
unique values or summing them, we pick out the maximum value.

``` r
max_items_filepath <- eider_example("max_drugs_in_transaction.json")
writeLines(readLines(max_items_filepath))
#> {
#>   "source_table": "pis",
#>   "transformation_type": "max",
#>   "grouping_column": "id",
#>   "absent_default_value": 0,
#>   "aggregation_column": "num_items",
#>   "output_feature_name": "max_drugs_in_transaction"
#> }
```

``` r
res <- run_pipeline(
  data_sources = list(pis = pis_data_filepath),
  feature_filenames = max_items_filepath
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 2
#> $ id                       <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,…
#> $ max_drugs_in_transaction <int> 4, 3, 5, 7, 5, 4, 4, 4, 6, 4, 5, 6, 3, 4, 3, …
```

## Feature 4: Maximum number of items prescribed in a single day

Now, consider a slightly more complicated request: what is the largest
number of items that were prescribed to a patient *in a single day*?
Clearly, this is also a `max` transformation type, but we need to now
somehow group together any rows that belong to the same patient and the
same date, and add up those values.

To do this, we can use `eider`’s preprocessing functionality, which is
described more thoroughly in [the preprocessing
vignette](https://alan-turing-institute.github.io/eider/docs/articles/preprocessing.md).
Specifically, we can:

- group by the `id` and `paid_date` columns;
- then replace the values in the `num_items` column with the sum of
  those values.

In JSON, these instructions can be specified using the `"preprocessing"`
key:

``` json
{
    ...,
    "preprocessing": {
        "on": ["id", "paid_date"],
        "replace_with_sum": "num_items"
    }
}
```

The full JSON file is the same as in [Feature
3](#feature-3-maximum-number-of-items-prescribed-in-a-single-transaction),
but just with this preprocessing block added in:

``` r
max_items_day_filepath <- eider_example("max_drugs_in_day.json")
writeLines(readLines(max_items_day_filepath))
#> {
#>   "source_table": "pis",
#>   "transformation_type": "max",
#>   "grouping_column": "id",
#>   "absent_default_value": 0,
#>   "aggregation_column": "num_items",
#>   "preprocess": {
#>     "on": [
#>       "id",
#>       "paid_date"
#>     ],
#>     "replace_with_sum": "num_items"
#>   },
#>   "output_feature_name": "max_drugs_in_day"
#> }
```

``` r
res <- run_pipeline(
  data_sources = list(pis = pis_data_filepath),
  feature_filenames = c(max_items_filepath, max_items_day_filepath)
)

dplyr::glimpse(res$features)
#> Rows: 20
#> Columns: 3
#> $ id                       <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,…
#> $ max_drugs_in_transaction <int> 4, 3, 5, 7, 5, 4, 4, 4, 6, 4, 5, 6, 3, 4, 3, …
#> $ max_drugs_in_day         <int> 4, 3, 8, 7, 5, 6, 8, 4, 6, 4, 5, 6, 3, 4, 3, …
```

Notice the differences between the two feature columns above: in the
second (`max_drugs_in_day`) we have successfully aggregated transactions
which happened on the same day, and thus the values (where they differ)
are larger.
