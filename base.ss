#lang scheme

; Dependencies -----------------------------------

(require (planet untyped/unlib:3/require))

(define-library-aliases webit      (planet jim/webit:1:5)           #:provide)
(define-library-aliases ssax       (planet lizorkin/ssax:2)         #:provide)
(define-library-aliases schemeunit (planet schematics/schemeunit:3) #:provide)
(define-library-aliases unlib      (planet untyped/unlib:3)         #:provide)

; Requires ---------------------------------------

(require srfi/26
         (unlib-in debug exn))

; Structure types --------------------------------

; Non-fatal exceptions:

(define-struct (exn:delicious exn) () #:transparent)

; Raised if bad credentials were supplied (HTTP code 401).
(define-struct (exn:delicious:auth exn:delicious) () #:transparent)

; Fatal exceptions:

(define-struct (exn:fail:delicious exn:fail) () #:transparent)

; Raised if delicious throttled a request (HTTP code 503).
(define-struct (exn:fail:delicious:throttled exn:fail:delicious) () #:transparent)

; Raised if we had a problem parsing the XML response data.
(define-struct (exn:fail:delicious:parse exn:fail:delicious) (fragment) #:transparent)

; Variables --------------------------------------

; The format in which del.icio.us sends/receives full timestamps
; (in the format accepted by SRFI 19's string->date and date->string).
;
; string
(define long-date-format "~Y-~m-~dT~H:~M:~SZ")

; The format in which del.icio.us sends/receives day-only dates
; (in the format accepted by SRFI 19's string->date and date->string).
;
; string
(define short-date-format "~Y-~m-~d")

; Provides ---------------------------------------

(provide (all-from-out srfi/26)
         (unlib-out debug exn)
         (all-defined-out))
