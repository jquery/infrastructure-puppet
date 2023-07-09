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

test: test-prod test-stage

test-stage: test-codeorigin-stage

test-prod: test-codeorigin-prod-http test-codeorigin-prod-https test-miscweb-prod

test-codeorigin-prod-http:
	@ php test/CodeoriginTest.php "http://code.jquery.com"
	@ echo "✅ $@"

test-codeorigin-prod-https:
	@ php test/CodeoriginTest.php "https://code.jquery.com"
	@ echo "✅ $@"

test-miscweb test-miscweb-prod:
	@ php test/MiscwebTest.php
	@ echo "✅ $@"

test-codeorigin-stage:
	@ php test/CodeoriginTest.php "https://codeorigin-02.stage.ops.jquery.net"
	@ echo "✅ $@"
