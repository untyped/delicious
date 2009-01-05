(module api-test mzscheme
  
  (require (lib "list.ss" "srfi" "1")
           (lib "time.ss" "srfi" "19")
           (lib "comprehensions.ss" "srfi" "42")
           (file "delicious.ss")
           (file "test-base.ss")
           (file "throttle.ss"))
  
  (provide api-tests)
  
  ; Test suite ----------------------------------
  
  ; The delay incurred by throttling means tests take a long time to run.
  ; This test suite is by no means comprehensive as a result.
  
  (define api-tests
    (test-suite
     "api.ss"
     
     #:before (lambda ()
                ; TODO : We keep getting throttled because of this...
                ; should probably avoid calling all-posts in these tests.
                (for-each delete-post! (all-posts))
                (for-each delete-bundle! (all-bundles)))
     
     #:after (lambda ()
                ; TODO : We keep getting throttled because of this...
                ; should probably avoid calling all-posts in these tests.
               (for-each delete-post! (all-posts))
               (for-each delete-bundle! (all-bundles)))
     
     (test-case
      "add-post! adds a post"
      (let* ([now  (time-tai->date (current-time time-tai))]
             [post (make-post "http://www.plt-scheme.org"
                              "PLT Scheme"
                              "The home of PLT Scheme"
                              (list "plt" "scheme")
                              now)])
        (check-not-exn (lambda ()
                         (add-post! post)))
        (let ([posts (get-posts)])
          (check-equal? (post-url (car posts)) "http://www.plt-scheme.org/")
          (check-equal? (post-description (car posts)) "PLT Scheme")
          (check-equal? (post-extended (car posts)) "The home of PLT Scheme")
          (check-equal? (post-tags (car posts)) (list "plt" "scheme"))
          ; TODO : Check created timestamp is roughly (but not quite)
          ; the timestamp on the original struct.
          )))
     
     ))
  
  )
 