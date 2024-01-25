# minisparra ❤️ quarto

Steps to build locally:

1. Install requisite packages in your R distribution.

       install.packages('tidyverse')
       install.packages('fst')
       install.packages('varhandle')

2. Install Quarto.

       install.packages('rmarkdown')
       brew install --cask quarto

3. From the `quarto` subdirectory (this one), run

       quarto preview
