all: doc test lint

test:
	Rscript -e "devtools::test()"

doc:
	Rscript -e "devtools::document(); devtools::build_readme()"

install:
	Rscript -e "devtools::install()"

lint:
	LINTR_ERROR_ON_LINT=true Rscript -e "lintr::lint_package()"

vig_serv:
	open http://localhost:8000/articles && python -m http.server -d docs 8000

vig_build:
	ls _pkgdown.yml vignettes/* | entr -s "Rscript -e 'pkgdown::build_articles(preview = FALSE)'"

site:
	Rscript -e "pkgdown::build_site()"

vig:
	sh -c "trap 'kill 0' SIGINT; make vig_build & make vig_serv"
