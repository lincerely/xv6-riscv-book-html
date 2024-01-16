# xv6-riscv-book in HTML

There are two pre-built html included:

 - `index.html` - for Github pages.
 - `xv6.html` - for offline use, link to local source code instead of Github.

Uses `pandoc` to build, see `Makefile` for more.

The SVG included is trimmed for rendered correctly in browser.

## Original readme 

This edition of the book has been converted to LaTeX.
In order to build it, ensure you have a TeX distribution that contains
the `pdflatex` command. With that, you should be able to build the book
by running `make`, which will clone the OS itself and build the book
to `book.pdf` in the main directory.

Figures are drawn using `inkscape`.
