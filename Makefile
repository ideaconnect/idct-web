HASH := $(shell date +%s%N | sha256sum | head -c 8)

.PHONY: build

build:
	rm -rf build/
	mkdir -p build/$(HASH)/styles build/$(HASH)/files
	cp index.html build/
	cp -r assets/files/. build/$(HASH)/files/
	cp assets/styles/main.css build/$(HASH)/styles/main.css
	cp assets/main.js build/$(HASH)/main.js
	minify -o build/$(HASH)/styles/main.css build/$(HASH)/styles/main.css
	minify -o build/$(HASH)/main.js build/$(HASH)/main.js
	sed -i 's|assets/|$(HASH)/|g' build/index.html
	@echo "Build complete: build/$(HASH)/"
