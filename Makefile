all: website

nanoc-version-3:
	@echo "Check running nanoc 3.x (if not, run . ./setpath)"
	test "`nanoc -v | sed -ne 's/nanoc \([^ ]*\) .*/\1/p' | cut -f1 -d.`" = "3"

website: nanoc-version-3
	@echo Compiling site
	mkdir -p output
	./extract-manual
	nanoc compile
	cp -rp external/ output/.

clean:
	rm -rf output crash.log
	rm -rf tmp content/firehol-manual content/fireqos-manual
