cmake_minimum_required (VERSION 3.2)

project (pppset)

install(PROGRAMS src/markdown2pdf DESTINATION bin)
install(FILES src/luatex-style.sty DESTINATION share/${PROJECT_NAME})

install(CODE "execute_process(COMMAND cabal install --global WORKING_DIRECTORY pandoc-include/)")
install(CODE "execute_process(COMMAND cabal install --global WORKING_DIRECTORY pandoc-autocomplete-caption/)")
