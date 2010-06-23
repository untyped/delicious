#lang scheme

(require net/uri-codec
         srfi/19
         "base.ss"
         "config.ss")

; URLs -----------------------------------------

; string [(U (alist-of symbol (U string symbol number boolean void)) #f)] -> string
(define format-url
  (let* ([format-argument-value
          (match-lambda
            [(? void? val)                  null]
            [(? string? val)                (uri-encode val)]
            [(? symbol? val)                (uri-encode (symbol->string val))]
            [(? number? val)                (uri-encode (number->string val))]
            [(? date? val)                  (date->string val long-date-format)]
            [(and vals `(,(? string?) ...)) (uri-encode (string-join vals " "))]
            [#t                             "yes"]
            [#f                             "no"])]
         [format-argument
          (match-lambda
            [(list-rest key (? void? val)) null]
            [(list-rest key val)
             (list (string-append (symbol->string key) "=" (format-argument-value val)))])])
    (lambda (path [arguments #f])
      (if arguments
          (string-append (current-base-url) path "?" (string-join (append-map format-argument arguments) "&"))
          (string-append (current-base-url) path)))))

; -> string
(define (last-updated-url)
  (format-url "/posts/update"))

; -> string
(define (get-tags-url)
  (format-url "/tags/get"))

; string string -> string
(define (rename-tag-url old new)
  (format-url "/tags/rename" `((old . ,old)
                               (new . ,new))))

;  [(U string void)]
;  [(U date void)]
;  [(U string void)]
; ->
;  string
(define (get-posts-url [tag (void)] [date (void)] [url (void)])
  (format-url "/posts/get" `((tag . ,tag)
                             (dt  . ,date)
                             (url . ,url))))

; [(U string void)] [(U number void)] -> string
(define (recent-posts-url [tag (void)] [count (void)])
  (format-url "/posts/recent" `((tag   . ,tag)
                                (count . ,count))))

; [(U string void)] -> string
(define (all-posts-url [tag (void)])
  (format-url "/posts/all" `((tag . ,tag))))

; [(U string void)] -> string
(define (post-dates-url [tag (void)])
  (format-url "/posts/dates" `((tag . ,tag))))

;  string
;  string
;  [(U string void)]
;  [(U (list-of string) (void))]
;  [(U date void)]
;  [(U boolean void)]
;  [(U boolean void)]
; ->
;  string
(define (add-post-url url description [extended (void)] [tags (void)] [date (void)] [replace? (void)] [shared? (void)])
  (format-url "/posts/add" `((url         . ,url)
                             (description . ,description)
                             (extended    . ,extended)
                             (tags        . ,tags)
                             (dt          . ,date)
                             (replace     . ,replace?)
                             (shared      . ,shared?))))

; string -> string
(define (delete-post-url url)
  (format-url "/posts/delete" `((url . ,url))))

; -> string
(define (all-bundles-url)
  (format-url "/tags/bundles/all"))

; string (list-of string) -> string
(define (set-bundle-url bundle tags)
  (format-url "/tags/bundles/set" `((bundle . ,bundle)
                                    (tags   . ,tags))))

; string  -> string
(define (delete-bundle-url bundle)
  (format-url "/tags/bundles/set" `((bundle . ,bundle))))

; Provide statements ---------------------------

; contract -> contract
(define (maybe/c contract)
  (or/c contract void?))

(provide maybe/c)

(provide/contract
 [last-updated-url  (-> string?)]
 [get-tags-url      (-> string?)]
 [rename-tag-url    (-> string? string? string?)]
 [get-posts-url     (->* ()
                         ((maybe/c string?)
                          (maybe/c date?)
                          (maybe/c string?))
                         string?)]
 [recent-posts-url  (->* ()
                         ((maybe/c string?) (maybe/c integer?))
                         string?)]
 [all-posts-url     (->* () ((maybe/c string?)) string?)]
 [post-dates-url    (->* () ((maybe/c string?)) string?)]
 [add-post-url      (->* (string? string?)
                         ((maybe/c string?)
                          (maybe/c (listof string?))
                          (maybe/c date?)
                          (maybe/c boolean?)
                          (maybe/c boolean?))
                         string?)]
 [delete-post-url   (-> string? string?)]
 [all-bundles-url   (-> string?)]
 [set-bundle-url    (-> string? (listof string?) string?)]
 [delete-bundle-url (-> string? string?)])
