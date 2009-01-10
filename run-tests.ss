(module run-tests mzscheme
  
  (require (file "all-tests.ss")
           (file "config.ss")
           (file "test-base.ss")
           (file "throttle.ss"))

  (begin (kill-throttle! (current-throttle))
         (parameterize ([current-throttle (make-throttle 5000)]
                        [current-username "plttest"]
                        [current-password "jej1ima"])
           (test/text-ui all-tests)))
  
  )
