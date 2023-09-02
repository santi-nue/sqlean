# Copyright (c) 2021 Anton Zhiyanov, MIT License
# https://github.com/nalgeon/sqlean

.PHONY: test

SQLITE_RELEASE_YEAR := 2021
SQLITE_VERSION := 3360000
SQLITE_BRANCH := 3.36

SQLEAN_VERSION := '"$(or $(shell git tag --points-at HEAD),main)"'

LINIX_FLAGS := -Wall -Wsign-compare -Wno-unknown-pragmas -fPIC -shared -Isrc -DSQLEAN_VERSION=$(SQLEAN_VERSION)
WINDO_FLAGS := -shared -Isrc -DSQLEAN_VERSION=$(SQLEAN_VERSION)
MACOS_FLAGS := -Wall -Wsign-compare -fPIC -dynamiclib -Isrc -DSQLEAN_VERSION=$(SQLEAN_VERSION)

prepare-dist:
	mkdir -p dist
	rm -rf dist/*

download-sqlite:
	curl -L http://sqlite.org/$(SQLITE_RELEASE_YEAR)/sqlite-amalgamation-$(SQLITE_VERSION).zip --output src.zip
	unzip src.zip
	mv sqlite-amalgamation-$(SQLITE_VERSION)/* src

download-external:
	curl -L https://github.com/mackyle/sqlite/raw/branch-$(SQLITE_BRANCH)/src/test_windirent.h --output src/test_windirent.h



compile-windows:
	gcc -O1 $(WINDO_FLAGS) src/sqlite3-crypto.c src/crypto/*.c -o dist/crypto.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-define.c src/define/*.c -o dist/define.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-fileio.c src/fileio/*.c -o dist/fileio.dll
	gcc -O1 $(WINDO_FLAGS) src/sqlite3-fuzzy.c src/fuzzy/*.c -o dist/fuzzy.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-math.c src/math/*.c -o dist/math.dll -lm
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-regexp.c -include src/regexp/constants.h src/regexp/*.c src/regexp/pcre2/*.c -o dist/regexp.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-stats.c src/stats/*.c -o dist/stats.dll -lm
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-text.c src/text/*.c -o dist/text.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-unicode.c src/unicode/*.c -o dist/unicode.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-uuid.c src/uuid/*.c -o dist/uuid.dll
	gcc -O3 $(WINDO_FLAGS) src/sqlite3-vsv.c src/vsv/*.c -o dist/vsv.dll -lm
	gcc -O1 $(WINDO_FLAGS) -include src/regexp/constants.h src/sqlite3-sqlean.c src/crypto/*.c src/define/*.c src/fileio/*.c src/fuzzy/*.c src/math/*.c src/regexp/*.c src/regexp/pcre2/*.c src/stats/*.c src/text/*.c src/unicode/*.c src/uuid/*.c src/vsv/*.c -o dist/sqlean.dll -lm

pack-windows:
	7z a -tzip dist/sqlean-win-x64.zip ./dist/*.dll

