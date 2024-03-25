
<!-- README.md is generated from README.Rmd. Please edit that file -->

# eider

<!-- badges: start -->
<!-- badges: end -->

The goal of eider is to … **TODO**

## Installation

You can install the development version of eider from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("alan-turing-institute/eider")
```

TODO: write some examples

``` r
library(eider)
```

## Development

If you are making changes to the library itself, first clone the
repository:

    git clone git@github.com:alan-turing-institute/eider.git

You will need to install the `lintr`, `pkgdown`, `devtools` R packages
to build documentation, run tests, and lint. Then, from the repository
root, you can use the following commands:

- `make doc` generates all function documentation, and also generates
  the `README.md` file from `README.rmd`
- `make lint` lints the project directory
- `make test` runs all tests

You can also use [`pre-commit`](https://pre-commit.com/) to run all of
these before committing, to ensure that you do not commit incomplete
code. Firstly, install `pre-commit` according to the instructions on the
webpage above. Then run `pre-commit install`.

*What about vignettes?* Well, building vignettes is slightly more
complicated. You can perform a one-time build from the R console using
`pkgdown::build_site()`, but running this every time you edit a file
gets tiring quickly. To automate this, first install the package with
`make install`, and install a working version of Python and also
[`entr`](https://github.com/eradman/entr) (the latter is available on
Homebrew via `brew install entr`). Then run `make vig`: this will
monitor your vignette RMarkdown files, rebuild the vignettes any time
they are changed, and launch a HTTP server on port 8000 to view the
files. If you change any library code you will have to run
`make install` again before rerunning `make vig`.
