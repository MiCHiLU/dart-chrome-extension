.SUFFIXES: .yaml .json
.yaml.json:
	assets/yaml2json$(GO_BIN_SUFFIX) $< |assets/jq$(GO_BIN_SUFFIX) '.' > $@

all: chrome-extensions

AUTO_VERSOINING=yes
RESOURCE_DIR_PATH=web
RESOURCE_DIR=$(foreach dir,$(shell find $(RESOURCE_DIR_PATH) -type d),$(dir))
YAML=$(shell find web -type f -name "[^.]*.yaml")
JSON=$(YAML:.yaml=.json)
RESOURCE=$(JSON) $(DART_JS)
VERSION=web/version
ifeq ($(shell uname -s),Darwin)
	GO_BIN_SUFFIX=-darwin-amd64
else
	GO_BIN_SUFFIX=-linux-amd64
endif

VERSION_DATE=$(shell git log --max-count=1 --pretty=tformat:%ad --date=short|sed s/-0/-/g|sed s/-/./g)
VERSION_NUMBER=$(shell git log --oneline --no-merges|wc -l|tr -d " ")
VERSION_STRING=$(shell git describe --always --dirty=+)
$(VERSION): web/manifest.json
ifdef AUTO_VERSOINING
	@if [ "$(VERSION_STRING)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION_STRING) > $@' ;\
		echo $(VERSION_STRING) > $@ ;\
	fi;
	sed -i "" -E 's/("version"[^"]+)"[^"]*"/\1"$(VERSION_DATE).$(VERSION_NUMBER)"/' web/manifest.json
else
	@echo -n
endif

DART=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.dart))
DART_JS=web/main.dart.js
$(DART_JS): pubspec.yaml $(DART)
	pub build --mode=debug

chrome-extensions: $(VERSION) $(RESOURCE)

REPOSITORY=$(shell git remote -v|grep origin|grep fetch|awk '{print $$2}')

clean:
	rm -f $(VERSION) $(RESOURCE)

clean-all: clean
	rm -f pubspec.lock $(DART_JS)
	rm -rf packages
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	find . -name packages -type l -delete

.PHONY: $(VERSION)
