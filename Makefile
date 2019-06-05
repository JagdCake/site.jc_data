.PHONY: all

.PHONY: create-prod-dir
.PHONY: copy-files-to-prod
.PHONY: generate-html
.PHONY: uncomment
.PHONY: fix-filepaths
.PHONY: build-html
.PHONY: build-css
.PHONY: build-js
.PHONY: optimize-images
.PHONY: test

dir.dev = ./public/
dir.prod = ./docs/

dir.dev.css = $(dir.dev)/css/
dir.dev.js = $(dir.dev)/js/
dir.dev.images = $(dir.dev)/images/

dir.prod.css = $(dir.prod)/css/
dir.prod.js = $(dir.prod)/js/
dir.prod.images = $(dir.prod)/images/

css.dev = $(dir.dev.css)/main.css
js.dev = $(dir.dev.js)/index.js

html.prod = $(dir.prod)/index.html
css.prod = $(dir.prod.css)/main.css
js.prod = $(dir.prod.js)/index.js
#
minify.html = html-minifier --case-sensitive --collapse-whitespace --remove-comments --minify-css --file-ext html
minify.css = csso
minify.js = terser --compress --mangle

optimize.png = optipng -o5
optimize.svg = svgo

test.php = bin/phpunit --testdox
test.php.files =

all: test create-prod-dir copy-files-to-prod generate-html uncomment-csp fix-filepaths build-html build-css build-js optimize-images

create-prod-dir:
	mkdir $(dir.prod)/
	mkdir $(dir.prod.css)/
	mkdir $(dir.prod.js)/
	mkdir $(dir.prod.images)/

copy-files-to-prod:
	cp ./templates/javascript.html $(dir.prod)/
	cp $(css.dev) $(css.prod)
	cp $(js.dev) $(js.prod)
	cp -r $(dir.dev.images) $(dir.prod)/

# "sleep" gives the server some time to start
generate-html:
	bin/console server:start 8000 && \
	sleep 2 && \
	curl localhost:8000/generate && \
	bin/console server:stop

uncomment-csp:
	sed -i 's/<!-- <meta http-equiv="Content-Security-Policy"/<meta http-equiv="Content-Security-Policy"/' $(html.prod)
	sed -i 's/upgrade-insecure-requests"> -->/upgrade-insecure-requests">/' $(html.prod)

fix-filepaths:
	sed -i 's/\/css\/main.css/css\/main.css/g' $(html.prod)
	sed -i 's/href="\/javascript"/href="javascript.html"/g' $(html.prod)
	sed -i 's/\/js\/index.js"/js\/min.index.js"/g' $(html.prod)

build-html:
	$(minify.html) --input-dir $(dir.prod)/ --output-dir $(dir.prod)/

build-css:
	$(minify.css) --input $(css.prod) --output $(css.prod)

build-js:
	$(minify.js) --output $(dir.prod.js)/min.index.js $(js.prod)

optimize-images:
	$(optimize.png) $(dir.prod.images)/*.png
	$(optimize.svg) -f $(dir.prod.images)/

test:
	$(test.php) $(test.php.files)
