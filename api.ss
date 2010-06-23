#lang scheme

(require "base.ss")

(require srfi/19
         "config.ss"
         "request.ss"
         "result-parse.ss"
         "result-struct.ss"
         "url.ss")

; API wrapper procedures -----------------------

; -> date
(define (last-updated)
  (parse-update-element
   (send-request (last-updated-url))))

; -> (alist-of string integer)
(define (get-tags)
  (parse-tags-element
   (send-request (get-tags-url))))

; string string -> void
(define (rename-tag! old new)
  (parse-result-element
   (send-request (rename-tag-url old new))))

;  [(U string void)]
;  [(U date void)]
;  [(U string void)]
; ->
;  (listof post)
(define (get-posts [tag (void)] [date (void)] [url (void)])
  (parse-posts-element
   (send-request (get-posts-url tag date url))))

; [(U string void)] [(U number void)] -> (listof post)
(define (recent-posts [tag (void)] [count (void)])
  (parse-posts-element
   (send-request (recent-posts-url tag count))))

; [(U string void)] -> (listof post)
(define (all-posts [tag (void)])
  (parse-posts-element
   (send-request (all-posts-url tag))))

; [(U string void)] -> (alist-of date integer)
(define (post-dates [tag (void)])
  (parse-dates-element
   (send-request (post-dates-url tag))))

;  post
;  [(U boolean void)]
;  [(U boolean void)]
; ->
;  void
(define (add-post! p [replace? (void)] [shared? (void)])
  (match p
    [(struct post (url description extended tags date))
     (add-post/raw! url
                    description
                    (if extended extended (void))
                    (if (null? tags) (void) tags)
                    (if date date (void))
                    replace?
                    shared?)]))

;  string
;  string
;  [(U string void)]
;  [(U (listof string) void)]
;  [(U date void)]
;  [(U boolean void)]
;  [(U boolean void)]
; ->
;  void
(define (add-post/raw! url description [extended (void)] [tags (void)] [date (void)] [replace? (void)] [shared? (void)])
  (parse-result-element
   (send-request (add-post-url url description extended tags date replace? shared?))))

; post -> void
(define (delete-post! post)
  (delete-post/raw! (post-url post)))

; string -> void
(define (delete-post/raw! url)
  (parse-result-element
   (send-request (delete-post-url url))))

; -> (listof bundle)
(define (all-bundles)
  (parse-bundles-element
   (send-request (all-bundles-url))))

; bundle -> void
(define (update-bundle! bundle)
  (update-bundle/raw! (bundle-name bundle)
                      (bundle-tags bundle)))

; string (listof string) -> void
(define (update-bundle/raw! name tags)
  (parse-result-element
   (send-request (set-bundle-url name tags))))

; bundle -> void
(define (delete-bundle! bundle)
  (delete-bundle/raw! (bundle-name bundle)))

; string -> void
(define (delete-bundle/raw! name)
  (parse-result-element
   (send-request (delete-bundle-url name))))

; Provide statements --------------------------- 

(provide/contract
 [last-updated       (-> date?)]
 [get-tags           (-> (listof (cons/c string? integer?)))]
 [rename-tag!        (-> string? string? void?)]
 [get-posts          (->* ()
                          ((maybe/c string?)
                           (maybe/c date?)
                           (maybe/c string?))
                          (listof post?))]
 [recent-posts       (->* ()
                          ((maybe/c string?) (maybe/c (and/c integer? (between/c 0 100))))
                          (listof post?))]
 [all-posts          (->* () ((maybe/c string?)) (listof post?))]
 [post-dates         (->* () ((maybe/c string?)) (listof (cons/c date? integer?)))]
 [add-post!          (->* (post?)
                          ((maybe/c boolean?)
                           (maybe/c boolean?))
                          void?)]
 [add-post/raw!      (->* (string? string?)
                          ((maybe/c string?)
                           (maybe/c (listof string?))
                           (maybe/c date?)
                           (maybe/c boolean?)
                           (maybe/c boolean?))
                          void?)]
 [delete-post!       (-> post? void?)]
 [delete-post/raw!   (-> string? void?)]
 [all-bundles        (-> (listof string?))]
 [update-bundle!     (-> bundle? void?)]
 [update-bundle/raw! (-> string? (listof string?) void?)]
 [delete-bundle!     (-> bundle? void?)]
 [delete-bundle/raw! (-> string? void?)])
