ifndef site
site = $(shell git br 2> /dev/null | sed -n -e 's/^\* *//p')
endif

c=firehol-manual.css
m=firehol-manual.html
s=firehol-services.html

all: website

website:
	@echo Compiling site $(site)
	mkdir -p output
	./extract-manual
	nanoc compile

tmp/$(m):
	mkdir -p tmp
	wget -q -O tmp/$(m) http://$(site).firehol.org/$(m)

tmp/$(s):
	mkdir -p tmp
	wget -q -O tmp/$(s) http://$(site).firehol.org/$(s)

tmp/$(c):
	mkdir -p tmp
	wget -q -O tmp/$(c) http://$(site).firehol.org/$(c)

tmp/$(site).firehol.org/firehol-manual/:
	(cd tmp; wget -q -r --no-parent http://$(site).firehol.org/firehol-manual/)

fakeman: tmp/$(m) tmp/$(s) tmp/$(c) website tmp/$(site).firehol.org/firehol-manual/
	cp -rp tmp/$(c) output/
	cp -rp tmp/$(m) output/
	cp -rp tmp/$(s) output/
	cp -rp tmp/$(site).firehol.org/firehol-manual/ output/
	mkdir -p output/download/latest
	mkdir -p output/download/releases
	mkdir -p output/download/unsigned/master
	touch output/download/index.html
	touch output/download/latest/index.html
	touch output/download/releases/index.html
	touch output/download/unsigned/index.html
	touch output/download/unsigned/master/index.html

clean:
	rm -rf output crash.log

cleanall: clean
	rm -rf tmp content/manual content/manual.md
	git checkout HEAD content/manual.html
