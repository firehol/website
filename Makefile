m=firehol-manual.html
mp=/home/web/firehol/download/unsigned/master/$(m)
s=firehol-services.html
sp=/home/web/firehol/download/unsigned/master/$(s)

all: site

site: tmp/$(m) tmp/$(s)
	mkdir -p output
	nanoc compile

tmp/$(m):
	mkdir -p tmp
	test -f $(mp) && cp $(mp) tmp/. || wget -q -O tmp/$(m) http://firehol.org/$(m)

tmp/$(s):
	mkdir -p tmp
	test -f $(sp) && cp $(sp) tmp/. || wget -q -O tmp/$(s) http://firehol.org/$(s)

fakeman: site
	cp -rp ../firehol/doc/*.html output
	cp -rp ../firehol/doc/*.css output
	rm -rf output/firehol-manual
	cp -rp ../firehol/doc/html output/firehol-manual

clean:
	rm -rf output crash.log

cleanall: clean
	rm -rf tmp
