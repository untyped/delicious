#lang scheme

(require "test-base.ss")

(require srfi/19
         "main.ss"
         "throttle.ss")

; Tests ------------------------------------------

; The delay incurred by throttling means tests take a long time to run.
; This test suite is by no means comprehensive as a result.

(define/provide-test-suite api-tests
  
  #:before
  (lambda ()
    ; TODO : We keep getting throttled because of this...
    ; should probably avoid calling all-posts in these tests.
    (for-each delete-post! (all-posts))
    (for-each delete-bundle! (all-bundles)))
  
  #:after
  (lambda ()
    ; TODO : We keep getting throttled because of this...
    ; should probably avoid calling all-posts in these tests.
    (for-each delete-post! (all-posts))
    (for-each delete-bundle! (all-bundles)))
  
  (test-case "add-post! adds a post"
    (let* ([now  (time-tai->date (current-time time-tai))]
           [post (make-post "http://www.racket-lang.org"
                            "Racket"
                            "The home of Racket"
                            (list "plt" "racket")
                            now)])
      (check-not-exn (lambda ()
                       (add-post! post)))
      (let ([posts (get-posts)])
        (check-equal? (post-url (car posts)) "http://www.racket-lang.org/")
        (check-equal? (post-description (car posts)) "Racket")
        (check-equal? (post-extended (car posts)) "The home of Racket")
        (check-equal? (post-tags (car posts)) (list "plt" "racket"))
        ; TODO : Check created timestamp is roughly (but not quite)
        ; the timestamp on the original struct.
        ))))
