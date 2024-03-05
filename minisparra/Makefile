all: doc test

test:
	Rscript -e "devtools::test()"

doc:
	Rscript -e "devtools::document(); devtools::document()"

lint:
	LINTR_ERROR_ON_LINT=true Rscript -e "lintr::lint_package()"

vig_serv:
	open http://localhost:8000 && python -m http.server -d doc 8000

vig_build:
	ls vignettes/* | entr -s "Rscript -e 'devtools::build_vignettes(install = TRUE)'"

vig:
	sh -c "trap 'kill 0' SIGINT; make vig_build & make vig_serv"
