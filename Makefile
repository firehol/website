all: website

website:
	@echo Compiling site
	mkdir -p output
	./extract-manual
	nanoc compile
	cp -rp external/ output/.

clean:
	rm -rf output crash.log
	rm -rf tmp content/firehol-manual content/fireqos-manual
