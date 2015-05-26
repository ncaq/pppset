cmake_minimum_required (VERSION 2.8)

project (pppset)

install(PROGRAMS src/markdown2article DESTINATION bin)
install(PROGRAMS src/markdown2slide DESTINATION bin)
install(FILES src/article.sty DESTINATION share/${PROJECT_NAME})
install(FILES src/beamer.sty DESTINATION share/${PROJECT_NAME})

install(CODE "execute_process(COMMAND cabal install --global WORKING_DIRECTORY pandoc-autocomplete-caption/)")
install(CODE "execute_process(COMMAND cabal install --global WORKING_DIRECTORY pandoc-include/)")
install(CODE "execute_process(COMMAND cabal install --global WORKING_DIRECTORY pandoc-minted/)")
