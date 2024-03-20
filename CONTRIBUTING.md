# eider

Reincarnation of SPARRA as a new bird

## Package documentation

https://alan-turing-institute.github.io/eider/docs/


## Setting up pre-commit

Installation is:

```bash
pip install pre-commit   # or brew install
pre-commit install
```

Once this is done, every time you commit, it will automatically run `devtools::document()`.
If `document()` generated new files (i.e. if you hadn't run `document()` yourself before committing), the commit will not go through:
you have to manually `git add` the new files and then commit again.
