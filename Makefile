BINDIR = $(PWD)/node_modules/.bin

SRC = utils querystring router model collection paginated-collection view-model error-model
SRC := $(SRC) item-view collection-view composite-view form-view store application trailer
SRC := $(SRC:%=src/%.coffee)

dist/_base.js: $(SRC)
	$(BINDIR)/coffee -j -b -c -p $(SRC) > dist/_base.js

dist/highbrow.js: dist/_base.js src/header-browser.js
	cat src/header-browser.js dist/_base.js > dist/highbrow.js

lib/highbrow.js: dist/_base.js src/header-node.js src/handlers.coffee
	$(BINDIR)/coffee -b -c -p src/handlers.coffee > dist/_handlers.js
	cat src/header-node.js dist/_base.js dist/_handlers.js > lib/highbrow.js

dist: dist/highbrow.js

lib: lib/highbrow.js

all: lib dist

clean:
	rm -f dist/_base.js
	rm -f dist/_handlers.js
	rm -f dist/highbrow.js
	rm -f lib/highbrow.js

docco:
	docco src/*.coffee
	git stash -u
	git checkout gh-pages
	rm -r docs
	git stash pop
	git commit -a -m "updating docs"
	git push origin gh-pages
	git checkout master

.DEFAULT_GOAL := all
#?
