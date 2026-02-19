HASH := $(shell date +%s%N | sha256sum | head -c 8)

.PHONY: build image container

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

image:
	docker buildx build --platform linux/arm64 --load -t idct/web -f docker/Dockerfile docker/
	docker save idct/web | gzip > image.tar.gz
	@echo "Image exported to image.tar.gz"

container:
	docker buildx build --platform linux/arm64 --load -t idct/web -f docker/Dockerfile docker/
	docker create --name idct_web_export idct/web
	docker export idct_web_export | gzip > container.tar.gz
	docker rm idct_web_export
	@echo "Container exported to container.tar.gz"
