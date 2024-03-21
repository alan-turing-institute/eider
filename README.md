# eider

Reincarnation of SPARRA as a new bird

# Weekly meetings
Thursdays, usually 10:30 - 11:30. Notes [here](https://hackmd.io/@hdduncan/BJRce3fYa)


## Package documentation

Ideally: https://alan-turing-institute.github.io/eider/docs/
Currently: https://alan-turing-institute.github.io/SPARRA/docs/


## Setting up pre-commit

Installation is:

```bash
pip install pre-commit   # or brew install
pre-commit install
```

Once this is done, every time you commit, it will automatically run `devtools::document()`.
If `document()` generated new files (i.e. if you hadn't run `document()` yourself before committing), the commit will not go through:
you have to manually `git add` the new files and then commit again.
