bootstrap := bootstrap-3.1.1-dist

files := index.html tutorial.html
deps = bootstrap-custom.css background.jpg
install := $(files) $(deps)

all: $(files)

install: $(files)
	-mkdir -p $(HOME)/public_html/wreq
	cp -a $(install) $(HOME)/public_html/wreq
	cp -a $(bootstrap) $(HOME)/public_html/wreq

%.html: %.md template.html $(deps)
	pandoc $< -o $@ --smart --template template.html \
	  --css $(bootstrap)/css/bootstrap.css \
	  --css bootstrap-custom.css \
	  --toc --toc-depth 2

clean:
	-rm -f $(files)
