#lang scheme

(require "test-base.ss")

(require "throttle.ss")

; Sleeps for the specified number of milliseconds.
;
; integer -> void
(define (sleep/ms ms)
  (sync (alarm-evt (+ (current-inexact-milliseconds) ms))))

; throttle integer integer -> test-suite
(define (make-throttle-suite throttle delay tolerance)
  (let ([do-throttle (lambda (thunk) (call-with-throttle throttle thunk))])
    (test-suite (format "~ams delay" delay)
      
      ; This test is brittle -- it depends on being
      ; evaluated before any other calls to
      ; call-with-throttle
      (test-case "First call to throttle happens immediately"
        (let ([now (current-inexact-milliseconds)]
              [call-time 0])
          (do-throttle
           (lambda ()
             (set! call-time (current-inexact-milliseconds))))
          (check-= call-time now tolerance)))
      
      (test-case (format "Throttled calls are spaced at least ~ams apart" delay)
        (let ([times null])
          (for ([x (in-range 0 5)])
            (do-throttle
             (lambda ()
               (set! times (cons (current-inexact-milliseconds) times)))))
          (foldl (lambda (curr prev)
                   (check > (- prev curr) delay)
                   curr)
                 (car times)
                 (cdr times))))
      
      (test-case (format "Multi-threaded throttled calls are spaced at least ~ams apart" delay)
        (let ([times null])
          (let* ([channels (map (lambda _ (make-channel)) (list 0 1 2 3 4))]
                 [procs    (map (lambda (channel)
                                  (lambda ()
                                    (do-throttle
                                     (lambda ()
                                       (set! times (cons (current-inexact-milliseconds) times))))
                                    (channel-put channel #t)))
                                channels)])
            (for-each thread procs)
            (for-each channel-get channels)
            (foldl (lambda (curr prev)
                     (check > (- prev curr) delay)
                     curr)
                   (car times)
                   (cdr times)))))
      
      (test-case (format "Calls more than ~ams apart are not delayed" delay)
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
      
      (test-case "Throttle delay is measured from when the thunk finishes execution"
        (let ([start1 0]
              [start2 0])
          (do-throttle
           (lambda ()
             (set! start1 (current-inexact-milliseconds))
             (sleep/ms delay)))
          (do-throttle
           (lambda ()
             (set! start2 (current-inexact-milliseconds))))
          (check-= (- start2 start1) (* 2 delay) tolerance))))))

(define/provide-test-suite throttle-tests
  
  (make-throttle-suite (make-throttle 500) 500 50)
  (make-throttle-suite (make-throttle 250) 250 50)
  
  (test-case "throttle-alive? detects when a throttle has been killed with kill-throttle!"
    (let ([throttle (make-throttle 1000)])
      (check-true (throttle-alive? throttle))
      (kill-throttle! throttle)
      (check-false (throttle-alive? throttle))))
  
  (test-case "throttle-alive? detects when a throttle has been killed via custodian shutdown"
    (let ([custodian (make-custodian)])
      (let ([throttle (parameterize ([current-custodian custodian])
                        (make-throttle 1000))])
        (check-true (throttle-alive? throttle))
        (custodian-shutdown-all custodian)
        (check-false (throttle-alive? throttle))))))
