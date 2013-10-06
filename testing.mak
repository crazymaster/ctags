#	$Id$
#
#	Copyright (c) 1996-2002, Darren Hiebert
#
#	Development makefile for Exuberant Ctags, used to build releases.
#	Requires GNU make.

CTAGS_TEST = ./ctags
TEST_OPTIONS = -nu --c-kinds=+lpx

DIFF_OPTIONS = -U 0 -I '^!_TAG'
DIFF = if diff $(DIFF_OPTIONS) $(REF_FILE) $(TEST_FILE) > $(DIFF_FILE); then \
		echo "Passed" ; \
	  else \
		echo "FAILED: differences left in $(DIFF_FILE)" ; \
	  fi

.PHONY: test test.include test.fields test.extra test.linedir test.etags test.eiffel test.linux

test: test.include test.fields test.extra test.linedir test.etags test.eiffel test.linux

test.%: DIFF_FILE = Test/$@.diff
test.%:	TEST_FILE = Test/$@.test
test.%: REF_FILE = Test/$@.ref

TEST_INCLUDE_OPTIONS = $(TEST_OPTIONS) --format=1
test.include: $(CTAGS_TEST)
	@ echo -n "Testing tag inclusion..."
	@ $(CTAGS_TEST) -R $(TEST_INCLUDE_OPTIONS) -o Test/test.include.test Test
	@- $(DIFF)

TEST_FIELD_OPTIONS = $(TEST_OPTIONS) --fields=+afmikKlnsStz
test.fields: $(CTAGS_TEST)
	@ echo -n "Testing extension fields..."
	@ $(CTAGS_TEST) -R $(TEST_FIELD_OPTIONS) -o $(TEST_FILE) Test
	@- $(DIFF)

TEST_EXTRA_OPTIONS = $(TEST_OPTIONS) --extra=+fq --format=1
test.extra: $(CTAGS_TEST)
	@ echo -n "Testing extra tags..."
	@ $(CTAGS_TEST) -R $(TEST_EXTRA_OPTIONS) -o $(TEST_FILE) Test
	@- $(DIFF)

TEST_LINEDIR_OPTIONS = $(TEST_OPTIONS) --line-directives -n
test.linedir: $(CTAGS_TEST)
	@ echo -n "Testing line directives..."
	@ $(CTAGS_TEST) $(TEST_LINEDIR_OPTIONS) -o $(TEST_FILE) Test/line_directives.c
	@- $(DIFF)

#TEST_ETAGS_OPTIONS = -e
#test.etags: $(CTAGS_TEST)
#	@ echo -n "Testing TAGS output..."
#	@ $(CTAGS_TEST) -R $(TEST_ETAGS_OPTIONS) -o $(TEST_FILE) Test
#	@- $(DIFF)

TEST_EIFFEL_OPTIONS = $(TEST_OPTIONS) --format=1 --languages=eiffel
EIFFEL_DIRECTORY = $(ISE_EIFFEL)/library
HAVE_EIFFEL := $(shell ls -dtr $(EIFFEL_DIRECTORY) 2>/dev/null)
ifeq ($(HAVE_EIFFEL),)
test.eiffel:
	@ echo "No Eiffel library source found for testing"
else
test.eiffel: $(CTAGS_TEST)
	@ echo -n "Testing Eiffel tag inclusion..."
	@ $(CTAGS_TEST) -R $(TEST_EIFFEL_OPTIONS) -o $(TEST_FILE) $(EIFFEL_DIRECTORY)
	@- $(DIFF)
endif

TEST_LINUX_OPTIONS = $(TEST_OPTIONS) --fields=k
LINUX_KERNELS_DIRECTORY :=
LINUX_DIRECTORY := $(shell find $(LINUX_KERNELS_DIRECTORY) -maxdepth 1 -type d -name 'linux-[1-9]*' 2>/dev/null | tail -1)
ifeq ($(LINUX_DIRECTORY),)
test.linux:
	@ echo "No Linux kernel source found for testing"
else
test.linux: $(CTAGS_TEST)
	@ echo -n "Testing Linux tag inclusion..."
	@ $(CTAGS_TEST) -R $(TEST_LINUX_OPTIONS) -o $(TEST_FILE) $(LINUX_DIRECTORY)
	@- $(DIFF)
endif

TEST_ARTIFACTS = test.*.diff test.*.test test.*.ref

clean-test:
	rm -f $(TEST_ARTIFACTS)

# vi:ts=4 sw=4
