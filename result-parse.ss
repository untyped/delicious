#lang scheme

(require "base.ss")

(require srfi/19
         (webit-in xml)
         "result-struct.ss")

; Parsing XML elements ---------------------------

; -> void | exn:fail:delicious:parse
(define (raise-parse-exn fragment)
  (raise-exn exn:fail:delicious:parse
    "Failed to parse XML fragment."
    fragment))

; sxml -> void | exn:fail:delicious
(define (parse-result-element elem)
  (xml-match elem
    [(result code: ,message)
     (if (equal? message "done")
         (void)
         (raise-exn exn:fail
           (format "del.icio.us returned an error: ~s" message)))]
    [,any (raise-parse-exn elem)]))

; sxml -> date
(define (parse-update-element elem)
  (xml-match elem
    [(update time: ,time)
     (parse-long-date time)]
    [,any (raise-parse-exn elem)]))

; sxml -> (alist-of string integer)
(define (parse-tags-element elem)
  (xml-match elem
    [(tags ,tags ...)
     (map parse-tag-element tags)]
    [,any (raise-parse-exn elem)]))

; sxml -> (cons string integer)
(define (parse-tag-element elem)
  (xml-match elem
    [(tag tag:   ,tag
          count: ,count)
     (cons tag (parse-number count))]
    [,any (raise-parse-exn elem)]))

; sxml -> (list-of post)
(define (parse-posts-element elem)
  (xml-match elem
    [(posts user:   [,user   #f]
            tag:    [,tag    #f]
            dt:     [,date   #f]
            update: [,update #f]
            ,posts ...)
     (map parse-post-element posts)]
    [,any (raise-parse-exn elem)]))

; sxml -> post
(define (parse-post-element elem)
  (xml-match elem
    [(post href:        [,url         #f]
           description: [,description #f]
           extended:    [,extended    #f]
           tag:         [,tag         #f]
           time:        [,date        #f]
           others:      [,others      #f]
           hash:        [,hash        #f]
           ,rest ...)
     (printf "~a ~a ~a ~a ~a~n" 
             url 
             description
             extended
             (parse-list-of-strings tag)
             (parse-long-date date))
     (make-post url 
                description
                extended
                (parse-list-of-strings tag)
                (parse-long-date date))]
    [,any (error "Post not matched" elem)]))

; sxml -> (alist-of date integer)
(define (parse-dates-element elem)
  (xml-match elem
    [(dates user: [,user #f]
            tag:  [,tag  #f]
            ,dates ...)
     (map parse-date-element dates)]
    [,any (raise-parse-exn elem)]))

; sxml -> (cons date integer)
(define (parse-date-element elem)
  (xml-match elem
    [(date date:  ,date
           count: ,count)
     (cons (parse-short-date date)
           (parse-number count))]
    [,any (raise-parse-exn elem)]))

; sxml -> (list-of bundle)
(define (parse-bundles-element elem)
  (xml-match elem
    [(bundles ,bundles ...)
     (map parse-bundle-element bundles)]
    [,any (raise-parse-exn elem)]))

; sxml -> bundle
(define (parse-bundle-element elem)
  (xml-match elem
    [(bundle name: ,name
             tags: ,tags)
     (list name (parse-list-of-strings tags))]
    [,any (raise-parse-exn elem)]))

; Parsing atomic values --------------------------

; string -> date
(define (parse-long-date str)
  (string->date str long-date-format))

; string -> date
(define (parse-short-date str)
  (string->date str short-date-format))

; string -> number
(define parse-number string->number)

; string -> (list-of string)
(define (parse-list-of-strings str)
  (regexp-split #rx" " str))

; string -> boolean
(define (parse-boolean str)
  (equal? str "yes"))

; Provide statements --------------------------- --

; Really lax contract. We want this to be fast.
;
; contract
(define sxml/c pair?)

(provide/contract
 [parse-result-element  (-> sxml/c void?)]
 [parse-update-element  (-> sxml/c date?)]
 [parse-tags-element    (-> sxml/c (listof (cons/c string? integer?)))]
 [parse-posts-element   (-> sxml/c (listof post?))]
 [parse-dates-element   (-> sxml/c (listof (cons/c date? integer?)))]
 [parse-bundles-element (-> sxml/c (listof bundle?))])
