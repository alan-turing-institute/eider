# Combination features

*Combination features* are those which have `transformation_type` equal
to `combine_linear`, `combine_min`, and `combine_max`. These features
use the values of two or more subfeatures to create a new feature.
Because the form of the JSON required for combination features differs
from those of all other features, they are given special attention in
this vignette.

``` r
library(eider)
```

## JSON structure

Of all the top-level JSON keys specified in the [feature
overview](https://alan-turing-institute.github.io/eider/docs/articles/features.md),
only `output_feature_name` and `transformation_type` are still required
for combination features. As before, `output_feature_name` is the name
of the feature that will be created. The value of `transformation_type`
can be:

- `combine_linear`: calculate a linear combination of the features
- `combine_min`: calculate the minimum of the features
- `combine_max`: calculate the maximum of the features

On top of these, combination features require a `subfeature` key, which
is itself a JSON object. Its keys can be any string (though it helps to
be descriptive), and its values are the JSON objects which define those
subfeatures, *sans* `output_feature_name` (because those are not
required). Note that each subfeature may have a different `source_table`
key, which allows the subfeatures to come from different input tables.

For linear combinations, each subfeature must further contain a `weight`
key, which is a number that determines the coefficients of each feature
in the linear combination.

## Minimum and maximum combination

As before, let’s make up some data to illustrate this.

``` r
input_table <- data.frame(
  id = c(1, 1, 1, 1, 2, 2, 2, 2),
  diagnosis = c("A", "A", "A", "A", "A", "A", "B", "B")
)

input_table
#>   id diagnosis
#> 1  1         A
#> 2  1         A
#> 3  1         A
#> 4  1         A
#> 5  2         A
#> 6  2         A
#> 7  2         B
#> 8  2         B
```

Suppose we want to find the number of times a patient has been diagnosed
with “A” or the number of times they have been diagnosed with “B”,
whichever is *greater*.

The number of “A” diagnoses would ordinarily be specified using the
following JSON:

``` json
{
    "output_feature_name": "num_A",
    "source_table": "input_table",
    "transformation_type": "count",
    "absent_default_value": 0,
    "grouping_column": "id",
    "filter": {
        "column": "diagnosis",
        "type": "in",
        "value": ["A"]
    }
}
```

and the number of “B” diagnoses would be exactly identical to this,
except with “A” replaced with “B”.

The combination feature we seek can thus be specified as in
[`json_examples/combination1.json`](https://github.com/alan-turing-institute/eider/blob/main/vignettes/json_examples/combination1.json).
Each subfeature is exactly the same as above, except that the
`output_feature_name` key is omitted:

    {
      "output_feature_name": "max_of_A_and_B",
      "transformation_type": "combine_max",
      "subfeature": {
        "num_A": {
          "source_table": "input_table",
          "grouping_column": "id",
          "transformation_type": "count",
          "absent_default_value": 0,
          "filter": {
            "column": "diagnosis",
            "type": "in",
            "value": [
              "A"
            ]
          }
        },
        "num_B": {
          "source_table": "input_table",
          "grouping_column": "id",
          "transformation_type": "count",
          "absent_default_value": 0,
          "filter": {
            "column": "diagnosis",
            "type": "in",
            "value": [
              "B"
            ]
          }
        }
      }
    }

Running this gives us the expected values of 4 and 2 for the two
patients respectively:

``` r
results <- run_pipeline(
  data_sources = list(input_table = input_table),
  feature_filenames = "json_examples/combination1.json"
)

results$features
#>   id max_of_A_and_B
#> 1  1              4
#> 2  2              2
```

## Linear combination

Linear combinations allow you to calculate, for example, a weighted sum
of two features. Suppose we want to assign a score of 10 for every “A”
diagnosis and 20 for every “B” diagnosis. We can use the same JSON as
above, but with two minor modifications:

- the `transformation_type` key set to `combine_linear`
- the `weight` key is added to each subfeature, with an appropriate
  value

The result is
[`json_examples/combination2.json`](https://github.com/alan-turing-institute/eider/blob/main/vignettes/json_examples/combination2.json):

    {
      "output_feature_name": "linear",
      "transformation_type": "combine_linear",
      "subfeature": {
        "A_score": {
          "weight": 10,
          "source_table": "input_table",
          "grouping_column": "id",
          "transformation_type": "count",
          "absent_default_value": 0,
          "filter": {
            "column": "diagnosis",
            "type": "in",
            "value": [
              "A"
            ]
          }
        },
        "B_score": {
          "weight": 20,
          "source_table": "input_table",
          "grouping_column": "id",
          "transformation_type": "count",
          "absent_default_value": 0,
          "filter": {
            "column": "diagnosis",
            "type": "in",
            "value": [
              "B"
            ]
          }
        }
      }
    }

and running it:

``` r
results <- run_pipeline(
  data_sources = list(input_table = input_table),
  feature_filenames = "json_examples/combination2.json"
)

results$features
#>   id linear
#> 1  1     40
#> 2  2     60
```

Note that for a simple unweighted sum of features, all weights can be
set to 1; and to take the difference between two features, one weight
can be set to 1 and the other to -1.

## See also

[Feature 3 in the LTC example
vignette](https://alan-turing-institute.github.io/eider/docs/articles/examples_ltc.html#feature-3-number-of-conditions)
is an example of a combination feature, in this case, a sum of three
subfeatures.
