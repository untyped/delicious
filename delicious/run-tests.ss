(module run-tests mzscheme
  
  (require (planet "test.ss" ("schematics" "schemeunit.plt" 2)))
  (require (planet "text-ui.ss" ("schematics" "schemeunit.plt" 2)))
  (require "all-tests.ss")
  
  (test/text-ui all-tests)
  
  )
