(module all-tests mzscheme
  
  (require (file "api-test.ss")
           (file "test-base.ss")
           (file "throttle-test.ss"))
  
  (provide all-tests)
  
  (define all-tests
    (test-suite 
     "all-tests"
     throttle-tests
     api-tests))
  
  )
