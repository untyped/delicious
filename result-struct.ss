#lang scheme

(require srfi/19)

; Structure types ------------------------------

; (struct string string (U string #f) (list-of string) date)
(define-struct post (url description extended tags date) #:transparent)

; (struct string (list-of string))
(define-struct bundle (name tags) #:transparent)

; Provide statements --------------------------- 

(provide/contract
 [struct post   ([url         string?]
                 [description string?]
                 [extended    (or/c string? #f)]
                 [tags        (listof string?)]
                 [date        (or/c date? #f)])]
 [struct bundle ([name        string?]
                 [tags        (listof string?)])])
