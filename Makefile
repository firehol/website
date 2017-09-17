# We need a 3.8.x version
VER=_3.8.0_

all: website

run: website
	@echo "When Webrick has started, navigate to:"
	@echo "   http://localhost:3000/"
	nanoc $(VER) view

website:
	@echo Compiling site
	mkdir -p output
	./extract-manual
	nanoc $(VER) compile
	cp -rp external/ output/.

clean:
	rm -rf output crash.log
	rm -rf tmp content/firehol-manual content/fireqos-manual
