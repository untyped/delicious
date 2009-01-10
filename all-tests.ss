(module all-tests mzscheme
  
  (require (planet "test.ss" ("schematics" "schemeunit.plt" 2))
           (file "throttle-test.ss"))
  
  (provide all-tests)
  
  (define all-tests
    (test-suite 
     "all-tests"
     throttle-tests
     ))
  
  )
