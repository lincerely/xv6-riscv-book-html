SRC=xv6-riscv-src/

T=latex.out

TEX=\
	$(T)/acks.tex\
	$(T)/first.tex\
	$(T)/fs.tex\
	$(T)/interrupt.tex\
	$(T)/lock.tex\
	$(T)/lock2.tex\
	$(T)/mem.tex\
	$(T)/sched.tex\
	$(T)/sum.tex\
	$(T)/trap.tex\
	$(T)/unix.tex\

SPELLTEX=$(wildcard *.tex)

all: book.pdf
.PHONY: all src clean html html-local

$(T)/%.tex: %.tex | src
	mkdir -p $(T)
	./lineref $(notdir $@) $(SRC) > $@

src:
	if [ ! -d $(SRC) ]; then \
		git clone https://github.com/mit-pdos/xv6-riscv $(SRC) ; \
	else \
		git -C $(SRC) pull ; \
	fi; \
	true

html: $(TEX)
	pandoc book.tex \
			--from latex --citeproc -M link-citations=true \
			-M lang=en -H style.html \
			--toc -s --number-sections --section-divs \
			--lua-filter indexer.lua \
			--lua-filter pdf2svg.lua --lua-filter latex_code2line.lua \
			--to html -o index.html

html-local: $(TEX)
	pandoc book.tex \
			--from latex --citeproc -M link-citations=true \
			-M lang=en -H style.html \
			--toc -s --number-sections --section-divs \
			--lua-filter indexer.lua \
			--lua-filter pdf2svg.lua --lua-filter local-link.lua \
			--lua-filter latex_code2line.lua \
			--to html -o xv6.html

book.pdf: src book.tex $(TEX)
	pdflatex book.tex
	bibtex book
	pdflatex book.tex
	pdflatex book.tex

clean:
	rm -f book.aux book.idx book.ilg book.ind book.log\
	 	book.toc book.bbl book.blg book.out
	#rm -rf $(T)
	rm -rf $(SRC)

spell:
	@ for i in $(SPELLTEX); do aspell --mode=tex -p ./aspell.words -c $$i; done
	@ for i in $(SPELLTEX); do perl bin/double.pl $$i; done
	@ for i in $(SPELLTEX); do perl bin/capital.py $$i; done
	@ ( head -1 aspell.words ; tail -n +2 aspell.words | sort ) > aspell.words~
	@ mv aspell.words~ aspell.words
