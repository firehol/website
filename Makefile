ifndef site
site = $(shell git br 2> /dev/null | sed -n -e 's/^\* *//p').
endif

c=firehol-manual.css
m=firehol-manual.html
s=firehol-services.html

all: website

website: tmp/$(m) tmp/$(s) tmp/$(c)
	@echo Compiling site $(site)
	mkdir -p output
	nanoc compile

tmp/$(m):
	mkdir -p tmp
	wget -q -O tmp/$(m) http://$(site)firehol.org/$(m)

tmp/$(s):
	mkdir -p tmp
	wget -q -O tmp/$(s) http://$(site)firehol.org/$(s)

tmp/$(c):
	mkdir -p tmp
	wget -q -O tmp/$(c) http://$(site)firehol.org/$(c)

tmp/$(site).firehol.org/firehol-manual/:
	(cd tmp; wget -q -r --no-parent http://$(site)firehol.org/firehol-manual/)

fakeman: website tmp/$(site).firehol.org/firehol-manual/
	cp -rp tmp/$(c) output/
	cp -rp tmp/$(m) output/
	cp -rp tmp/$(s) output/
	cp -rp tmp/$(site)firehol.org/firehol-manual/ output/

clean:
	rm -rf output crash.log

cleanall: clean
	rm -rf tmp
