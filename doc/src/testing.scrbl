#reader(lib "docreader.ss" "scribble")

@require[(file "base.ss")]

@title[#:tag "testing"]{Testing}

@lib-name has a reasonably comprehensive test suite, written using the
@italic{SchemeUnit} library. Use the following shell command to run the 
tests:

@commandline{mzscheme -mtv run-tests.ss}

The test suite uses a dedicated @api-name account to test API calls. The
@var{api-test} test suite automatically sets up the correct username and 
password, and deletes all posts and bundles before and after the relevant
tests.

Note that, because of throttling, the tests may take a while to run.
