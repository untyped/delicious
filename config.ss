#lang scheme

(require "base.ss"
         "throttle.ss")

; (parameter string)
(define current-username
  (make-parameter
   #f
   (lambda (val)
     (if (string? val)
         val
         (raise-exn exn:fail:contract
           (format "Expected string, received ~a." val))))))

; (parameter string)
(define current-password
  (make-parameter
   #f
   (lambda (val)
     (if (string? val)
         val
         (raise-exn exn:fail:contract
           (format "Expected string, received ~a." val))))))

; Gets/sets the base URL for the del.icio.us API, WITHOUT a trailing slash.
;
; Because ssl-url.ss does not understand the "https://" protocol, the URL must be of the form "http://api.del.icio.us:443/blah".
;
; (parameter string)
(define current-base-url
  (make-parameter
   "http://api.del.icio.us:443/v1"
   (lambda (val)
     (if (string? val)
         (if (eq? (string-ref val (sub1 (string-length val))) #\/)
             (raise-exn exn:fail:contract
               (format "Base URL must not have a trailing slash: ~a." val))
             val)
         (raise-exn exn:fail:contract
           (format "Expected string, received ~a." val))))))

; The throttle control to use to prevent requests being made too quickly.
;
; (parameter throttle)
(define current-throttle
  (make-parameter
   (make-throttle 1000)
   (lambda (val)
     (if (and (throttle? val) (>= (throttle-delay val) 1000))
         val
         (raise-exn exn:fail:contract
           (format "Expected throttle with a delay >= 1000ms, received ~a" val))))))

; (parameter boolean)
(define dump-request-urls?
  (make-parameter #f))

; (parameter boolean)
(define dump-sxml-responses?
  (make-parameter #f))

; Provide statements --------------------------- 

(provide/contract
 [current-username     (parameter/c string?)]
 [current-password     (parameter/c string?)]
 [current-base-url     (parameter/c string?)]
 [current-throttle     (parameter/c throttle?)]
 [dump-request-urls?   (parameter/c boolean?)]
 [dump-sxml-responses? (parameter/c boolean?)])
