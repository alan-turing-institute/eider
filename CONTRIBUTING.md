# Contributing to eider

Development work on `eider` was carried out from January to March 2024.
As of the time of writing, it is not under active development.

If you would like to file a bug, please do [open an issue on GitHub](https://github.com/alan-turing-institute/eider/issues/new)!
It will be *extremely helpful* if you can include a minimum viable example of what the bug is about.
Because `eider` often reads in data that is stored on the local file system, you should also provide the contents of these files.
This may include CSV files (for the input data) and JSON files (for the feature specifications).
Otherwise, it may be difficult or impossible to pinpoint the bug.

For broader questions about the package and further developemnt, feel free to create an issue, or get in touch with the maintainer: this means the person listed in the `DESCRIPTION` file with the role `"cre"`.


## Developer tools

There are a few `pre-commit` hooks which, if enabled, will ensure that you do not commit code that is inconsistent (e.g. `.Rd` documentation files which are not in sync with roxygen2 comments).
To use these, first [install `pre-commit` itself](https://pre-commit.com/).
Then make sure you have the `devtools` and `lintr` packages installed:

```r
install.packages(c("devtools", "lintr"))
```

You can then set up the pre-commit hooks to run every time before committing by running

```
pre-commit install
```

(from the shell, not from the R console).
