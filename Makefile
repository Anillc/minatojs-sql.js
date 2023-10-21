SQLITE_AMALGAMATION_ZIP_URL = https://www.sqlite.org/2022/sqlite-amalgamation-3390300.zip
SQLITE_AMALGAMATION_ZIP_SHA3 = 6a83b7da4b73d7148364a0033632ae1e4f9d647417e6f3654a5d0afe8424bbb9

# Note that extension-functions.c hasn't been updated since 2010-02-06, so likely doesn't need to be updated
EXTENSION_FUNCTIONS_URL = https://www.sqlite.org/contrib/download/extension-functions.c?get=25
EXTENSION_FUNCTIONS_SHA1 = c68fa706d6d9ff98608044c00212473f9c14892f

EMCC=emcc

SQLITE_COMPILATION_FLAGS = \
	-Oz \
	-DSQLITE_OMIT_LOAD_EXTENSION \
	-DSQLITE_DISABLE_LFS \
	-DSQLITE_ENABLE_FTS3 \
	-DSQLITE_ENABLE_FTS3_PARENTHESIS \
	-DSQLITE_THREADSAFE=0 \
	-DSQLITE_ENABLE_DBSTAT_VTAB \
	-DSQLITE_ENABLE_NORMALIZE

EMFLAGS = \
	--memory-init-file 0 \
	-s RESERVED_FUNCTION_POINTERS=64 \
	-s ALLOW_TABLE_GROWTH=1 \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s EXPORTED_FUNCTIONS=@src/exported_functions.json \
	-s EXPORTED_RUNTIME_METHODS=@src/exported_runtime_methods.json \
	-s SINGLE_FILE=0 \
	-s NODEJS_CATCH_EXIT=0 \
	-s NODEJS_CATCH_REJECTION=0 \
	-s WASM=1 \
	-s LEGACY_RUNTIME=1 \
	-s KOISHIFS=1 \
	--closure-args=--jscomp_off=checkTypes \
	--closure-args=--jscomp_off=checkVars

EMFLAGS_OPTIMIZED= \
	-Oz \
	-flto \
	--closure 1

EMFLAGS_DEBUG = \
	-s ASSERTIONS=1 \
	-O1

COFF_FILES = out/sqlite3.o out/extension-functions.o
OUTPUT_WRAPPER_FILES = src/shell-pre.js src/shell-post.js
SOURCE_API_FILES = src/api.js
EMFLAGS_PRE_JS_FILES = --pre-js src/api.js
EXPORTED_METHODS_JSON_FILES = src/exported_functions.json src/exported_runtime_methods.json

.PHONY: all debug optimized clean
all: optimized
debug: dist/sql-wasm-debug.js
optimized: dist/sql-wasm.js dist/sql-wasm.d.ts
clean:
	rm -rf out dist sqlite-src

dist/sql-wasm-debug.js: $(COFF_FILES) $(OUTPUT_WRAPPER_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	mkdir -p dist
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DEBUG) $(COFF_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@
	mv $@ out/tmp-raw.js
	cat src/shell-pre.js out/tmp-raw.js src/shell-post.js > $@
	rm out/tmp-raw.js

dist/sql-wasm.js: $(COFF_FILES) $(OUTPUT_WRAPPER_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	mkdir -p dist
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(COFF_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@
	mv $@ out/tmp-raw.js
	cat src/shell-pre.js out/tmp-raw.js src/shell-post.js > $@
	rm out/tmp-raw.js

dist/sql-wasm.d.ts: src/sql-wasm.d.ts
	cp src/sql-wasm.d.ts $@

out/sqlite3.o: sqlite-src
	mkdir -p out
	$(EMCC) $(SQLITE_COMPILATION_FLAGS) -c sqlite-src/sqlite3.c -o $@

out/extension-functions.o: sqlite-src
	mkdir -p out
	$(EMCC) $(SQLITE_COMPILATION_FLAGS) -c sqlite-src/extension-functions.c -o $@

TMP := $(shell mktemp -d)
sqlite-src:
	mkdir -p $@
	curl -LsSf '$(SQLITE_AMALGAMATION_ZIP_URL)' -o $(TMP)/sqlite.zip
	curl -LsSf '$(EXTENSION_FUNCTIONS_URL)' -o $(TMP)/extension-functions.c
	echo '$(SQLITE_AMALGAMATION_ZIP_SHA3)  $(TMP)/sqlite.zip' > $(TMP)/check.txt
	echo '$(EXTENSION_FUNCTIONS_SHA1)  $(TMP)/extension-functions.c' >> $(TMP)/check.txt
	sha3sum -a 256 -c $(TMP)/check.txt
	unzip -j $(TMP)/sqlite.zip -d $@
	cp $(TMP)/extension-functions.c $@
	rm -rf $(TMP)
