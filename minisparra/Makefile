all: doc test

test:
	Rscript -e "devtools::test()"

doc:
	Rscript -e "devtools::document(); devtools::document()"

lint:
	LINTR_ERROR_ON_LINT=true Rscript -e "lintr::lint_package()"
