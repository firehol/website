m=firehol-manual.html
s=firehol-services.html

ifndef site
site=www
endif

all: site

site: tmp/$(m) tmp/$(s)
	mkdir -p output
	nanoc compile

tmp/$(m):
	mkdir -p tmp
	wget -q -O tmp/$(m) http://$(site).firehol.org/$(m)

tmp/$(s):
	mkdir -p tmp
	wget -q -O tmp/$(s) http://$(site).firehol.org/$(s)

fakeman: site
	cp -rp ../firehol/doc/*.html output
	cp -rp ../firehol/doc/*.css output
	rm -rf output/firehol-manual
	cp -rp ../firehol/doc/html output/firehol-manual

clean:
	rm -rf output crash.log

cleanall: clean
	rm -rf tmp
