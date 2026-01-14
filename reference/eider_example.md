# Obtain filepaths to example data and JSON features

Return an absolute path to the example data and JSON features provided
with the package. These files are contained in the package
`inst/extdata` directory.

## Usage

``` r
eider_example(file = NULL)
```

## Arguments

- file:

  The filename to return the full path for. Defaults to `NULL`, in which
  case it will return a vector of all valid filenames.

## Value

A string containing the full path to the file, or a vector of filenames

## Examples

``` r
eider_example()
#>  [1] "ae_attendances_neurology_2017.json" "ae_total_attendances.json"         
#>  [3] "days_in_smr04.json"                 "days_since_last_ae.json"           
#>  [5] "distinct_bnf_prescriptions.json"    "has_asthma.json"                   
#>  [7] "has_visited_ae.json"                "longest_stay.json"                 
#>  [9] "max_drugs_in_day.json"              "max_drugs_in_transaction.json"     
#> [11] "num_prescriptions_since_2016.json"  "number_of_ltcs.json"               
#> [13] "psychotherapy_episodes.json"        "psychotherapy_stays.json"          
#> [15] "random_ae_data.csv"                 "random_ltc_data.csv"               
#> [17] "random_pis_data.csv"                "random_smr04_data.csv"             
#> [19] "years_with_asthma.json"            
eider_example("random_ae_data.csv")
#> [1] "/tmp/RtmpiKfwzZ/temp_libpath357d1cc17fe3/eider/extdata/random_ae_data.csv"
```
