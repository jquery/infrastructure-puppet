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
MAKEFLAGS += -j 4
endif

export DEBUG=0

.PHONY: lint test

all: lint

lint:
	puppet-lint --fail-on-warnings .

test: test-codeorigin-stage test-codeorigin-prod-http test-codeorigin-prod-https test-codeorigin-next-http test-codeorigin-next-https test-miscweb test-wpdocs

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

test-miscweb:
	@ php test/MiscwebTest.php
	@ echo "✅ $@"

test-wpdocs:
	@ php test/WpdocsTest.php
	@ echo "✅ $@"

test-codeorigin-stage:
	@ php test/CodeoriginTest.php "https://codeorigin-02.stage.ops.jquery.net"
	@ echo "✅ $@"
