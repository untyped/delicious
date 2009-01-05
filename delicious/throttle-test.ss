(module throttle-test mzscheme
  
  (require (lib "list.ss" "srfi" "1")
           (lib "comprehensions.ss" "srfi" "42")
           (planet "test.ss" ("schematics" "schemeunit.plt" 2))
           (file "throttle.ss"))
  
  (provide throttle-tests)
  
  ;; sleep/ms : integer -> void
  ;;
  ;; Sleeps for the specified number of milliseconds.
  (define (sleep/ms ms)
    (sync (alarm-evt (+ (current-inexact-milliseconds) ms))))
  
  ;; make-throttle-suite : throttle integer integer -> test-suite
  (define (make-throttle-suite throttle delay tolerance)
    (let ([do-throttle
           (lambda (thunk)
             (call-with-throttle throttle thunk))])
      (test-suite
       (format "~ams delay" delay)
       
       ;; This test is brittle -- it depends on being
       ;; evaluated before any other calls to
       ;; call-with-throttle
       (test-case
        "First call to throttle happens immediately"
        (let ([now (current-inexact-milliseconds)]
              [call-time 0])
          (do-throttle
           (lambda ()
             (set! call-time (current-inexact-milliseconds))))
          (check-= call-time now tolerance)))
       
       (test-case
        (format "Throttled calls are spaced at least ~ams apart" delay)
        (let ([times null])
          (do-ec (:range x 0 5)
                 (do-throttle
                  (lambda ()
                    (set! times (cons (current-inexact-milliseconds) times)))))
          (fold (lambda (curr prev)
                  (check > (- prev curr) delay)
                  curr)
                (car times)
                (cdr times))))
       
       (test-case
        (format "Multi-threaded throttled calls are spaced at least ~ams apart" delay)
        (let ([times null])
          (let* ([channels (map (lambda _ (make-channel)) (iota 5))]
                 [procs    (map (lambda (channel)
                                  (lambda ()
                                    (do-throttle
                                     (lambda ()
                                       (set! times (cons (current-inexact-milliseconds) times))))
                                    (channel-put channel #t)))
                                channels)])
            (for-each thread procs)
            (for-each channel-get channels)
            (fold (lambda (curr prev)
                    (check > (- prev curr) delay)
                    curr)
                  (car times)
                  (cdr times)))))
       
       (test-case
        (format "Calls more than ~ams apart are not delayed" delay)
        (do-throttle
         (lambda ()
           'foo))
        (sleep/ms delay)
        (let ([now (current-inexact-milliseconds)]
              [call-time 0])
          (do-throttle
           (lambda ()
             (set! call-time (current-inexact-milliseconds))))
          (check-= call-time now tolerance)))
       
       (test-case
        "Throttle delay is measured from when the thunk finishes execution"
        (let ([start1 0]
              [start2 0])
          (do-throttle
           (lambda ()
             (set! start1 (current-inexact-milliseconds))
             (sleep/ms delay)))
          (do-throttle
           (lambda ()
             (set! start2 (current-inexact-milliseconds))))
          (check-= (- start2 start1) (* 2 delay) tolerance)))
       
       )))
  
  (define throttle-tests
    (test-suite
     "throttle.ss"
     
     (make-throttle-suite (make-throttle 500) 500 50)
     (make-throttle-suite (make-throttle 250) 250 50)
     
     (test-case
      "throttle-alive? detects when a throttle has been killed with kill-throttle!"
      (let ([throttle (make-throttle 1000)])
        (check-true (throttle-alive? throttle) "check 1")
        (kill-throttle! throttle)
        (check-false (throttle-alive? throttle) "check 2")))
     
     (test-case
      "throttle-alive? detects when a throttle has been killed via custodian shutdown"
      (let ([custodian (make-custodian)])
        (let ([throttle (parameterize ([current-custodian custodian])
                          (make-throttle 1000))])
          (check-true (throttle-alive? throttle) "check 1")
          (custodian-shutdown-all custodian)
          (check-false (throttle-alive? throttle) "check 2"))))
     
     ))
  
  )
 