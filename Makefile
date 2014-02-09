m=firehol-manual.html
s=firehol-services.html

all: tmp/$(m) tmp/$(s)
	mkdir -p output
	nanoc compile

tmp/$(m):
	mkdir -p tmp
	wget -q -O tmp/$(m) http://firehol.org/$(m)

tmp/$(s):
	mkdir -p tmp
	wget -q -O tmp/$(s) http://firehol.org/$(s)

clean:
	rm -rf output crash.log

cleanall: clean
	rm -rf tmp
