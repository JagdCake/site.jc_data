.PHONY: all

.PHONY: create-prod-dir
.PHONY: copy-files-to-prod
.PHONY: generate-html
.PHONY: uncomment-csp
.PHONY: fix-filepaths
.PHONY: build-html
.PHONY: build-css
.PHONY: optimize-images
.PHONY: test

dir.dev = ./public/
dir.prod = ./docs/

dir.dev.css = $(dir.dev)/css/
dir.dev.images = $(dir.dev)/images/

dir.prod.css = $(dir.prod)/css/
dir.prod.images = $(dir.prod)/images/

css.dev = $(dir.dev.css)/tachyons.min.css

html.prod = $(dir.prod)/index.html
css.prod = $(dir.prod.css)/tachyons.min.css
#
minify.html = html-minifier --case-sensitive --collapse-whitespace --remove-comments --minify-css --file-ext html
minify.css = csso

optimize.png = optipng -o5

test.php = bin/phpunit --testdox
test.php.files =

all: test create-prod-dir copy-files-to-prod generate-html uncomment-csp fix-filepaths build-html build-css optimize-images

data-update: test save-last-update generate-html uncomment-csp fix-filepaths build-html

create-prod-dir:
	mkdir $(dir.prod)/
	mkdir $(dir.prod.css)/
	mkdir $(dir.prod.images)/

copy-files-to-prod:
	cp $(css.dev) $(css.prod)
	cp -r $(dir.dev.images) $(dir.prod)/

# finds the date of the last update and saves the data in a new file
last-update := $(shell grep -o -P '\d{4}-\d{2}-\d{2}' $(html.prod))
save-last-update:
	cp $(html.prod) $(dir.prod)/$(last-update).html

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
	sed -i 's/\/css\/tachyons.min.css/css\/tachyons.min.css/g' $(html.prod)

build-html:
	$(minify.html) --input-dir $(dir.prod)/ --output-dir $(dir.prod)/

build-css:
	@echo Make sure $(css.prod) is purged from unused rules, use uncss
	@echo Press enter to confirm
	@read
	$(minify.css) --input $(css.prod) --output $(css.prod)

optimize-images:
	$(optimize.png) $(dir.prod.images)/*.png

test:
	$(test.php) $(test.php.files)
