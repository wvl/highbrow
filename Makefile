BINDIR = $(PWD)/node_modules/.bin

SRC = $(shell find src -name "*.coffee")
SRCJS = $(SRC:src/%.coffee=lib/%.js)
SRC_REQUIRE_JS = $(SRCJS:lib/%.js=www/js/vendor/highbrow/%.js)

lib/%.js: src/%.coffee
	rm -f $@
	$(BINDIR)/coffee -b -o $(@D) -c $<

APPSRC = $(shell find app -name "*.coffee")
APPJS = $(APPSRC:app/%.coffee=www/js/app/%.js)

www/js/app/%.js: app/%.coffee
	mkdir -p $(@D)
	echo "define(function(require,exports,module) {\n" > $@
	$(BINDIR)/coffee -b -p -c $< >> $@
	echo "\n\nreturn module.exports;\n});" >> $@

www/js/vendor/highbrow/%.js: lib/%.js
	mkdir -p www/js/vendor/highbrow
	echo "define(function (require,exports,module) {\n" > $@
	cat $< >> $@
	echo "\n\nreturn module.exports;\n});" >> $@

VJS = require jquery underscore moment backbone nct model_binder
VJS := $(VJS:%=www/js/vendor/%.js)

dist/highbrow.js: $(SRC_REQUIRE_JS) highbrow.build.js
	$(BINDIR)/r.js -o highbrow.build.js
	mkdir -p dist
	cp release/highbrow/index.js dist/highbrow.js

release/deps.js: $(VJS) highbrow.build.js
	$(BINDIR)/r.js -o highbrow.build.js

release/app.js: $(APPJS) app.build.js
	$(BINDIR)/r.js -o app.build.js

www/js/vendor/require.js: node_modules/requirejs/require.js
	cp $< $@

www/js/vendor/jquery.js: vendor/js/jquery-1.8.1.min.js
	cp $< $@

www/js/vendor/underscore.js: node_modules/underscore/underscore-min.js
	cp $< $@

www/js/vendor/moment.js: node_modules/moment/moment.js
	cp $< $@

www/js/vendor/nct.js: node_modules/nct/dist/nct.js
	cp $< $@

www/js/vendor/backbone.js: node_modules/backbone/backbone.js
	cp $< $@

www/js/vendor/model_binder.js: vendor/js/Backbone.ModelBinder.js
	cp $< $@

NCT = $(shell find app/templates -name "*.nct")
NCT_COMPILED = $(NCT:app/templates/%.nct=www/js/app/templates/%.js)

www/js/app/templates/%.js: app/templates/%.nct
	mkdir -p $(@D)
	$(BINDIR)/nct --dir app/templates/ $< > $@

www/js/app/templates.js: $(NCT_COMPILED)
	echo "define(['nct','underscore'], function(nct, _) {" > $@
	cat $(NCT_COMPILED) $(NCC_COMPILED) >> $@
	echo "});" >> $@

prod: dist/highbrow.js release/app.js release/deps.js

dist: dist/highbrow.js

build: $(VJS) $(SRCJS) $(SRC_REQUIRE_JS) $(APPJS) www/js/app/templates.js

all: build prod

clean:
	rm $(VJS)
	rm $(SRCJS)
	rm $(SRC_REQUIRE_JS)
	rm $(APPJS)
	rm www/js/app/templates.js

docco:
	docco src/*.coffee
	git stash -u
	git checkout gh-pages
	rm -r docs
	git stash pop
	git commit -a -m "updating docs"
	git push origin gh-pages
	git checkout master

.DEFAULT_GOAL := build
#?
