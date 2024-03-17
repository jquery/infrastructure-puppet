#
# Usage:
#
# $ make lint
#
# $ make test
#
# $ make DEBUG=1 test-stage
#

ifndef MAKEFLAGS
MAKEFLAGS += -j 8
endif

export DEBUG=0

.PHONY: doc/wordpress.md build lint test

all: build lint

build: doc/wordpress.md

doc/wordpress.md:
	./bin/build_wordpress_md.sh

lint:
	puppet-lint --fail-on-warnings .
	@ ./bin/build_wordpress_md.sh --verify

test: test-codeorigin-prod-http test-codeorigin-prod-https test-codeorigin-next-http test-codeorigin-next-https test-codeorigin-stage test-contentorigin-prod test-miscweb test-wpdocs test-releases

test-codeorigin-prod-http:
	@ php test/CodeoriginTest.php "http://code.jquery.com"
	@ echo "✅ $@"

test-codeorigin-prod-https:
	@ php test/CodeoriginTest.php "https://code.jquery.com"
	@ echo "✅ $@"

test-codeorigin-next-http:
	@ php test/CodeoriginTest.php "http://codeorigin.jquery.com"
	@ echo "✅ $@"

test-codeorigin-next-https:
	@ php test/CodeoriginTest.php "https://codeorigin.jquery.com"
	@ echo "✅ $@"

test-codeorigin-stage:
	@ php test/CodeoriginTest.php "https://codeorigin-02.stage.ops.jquery.net"
	@ echo "✅ $@"

test-contentorigin-prod:
	@ php test/ContentoriginTest.php
	@ echo "✅ $@"

test-miscweb:
	@ php test/MiscwebTest.php
	@ echo "✅ $@"

test-wpdocs:
	@ php test/WpdocsTest.php
	@ echo "✅ $@"

test-releases:
	@ php test/ReleasesTest.php
	@ echo "✅ $@"
