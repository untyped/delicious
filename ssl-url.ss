#lang scheme

(require net/url-structs
         net/url-sig
         net/url-unit
         net/tcp-sig
         net/ssl-tcp-unit)

; Units ----------------------------------------

(define-unit-binding ssl-tcp@
  (make-ssl-tcp@ #f #f #f #f #f #f #f)
  (import)
  (export tcp^))

(define-compound-unit/infer url+tcp@
  (import)
  (export url^)
  (link ssl-tcp@ url@))

; Procedures -----------------------------------

(define-values/invoke-unit/infer url+tcp@)

; Provide statements --------------------------- 

(provide (struct-out url)
         (struct-out path/param))

(provide/contract
 [string->url                   (-> (or/c bytes? string?) url?)]
 [url->string                   (-> url? string?)]
 [path->url                     (-> (or/c path-string? path-for-some-system?) url?)]
 [url->path                     (->* (url?) ((one-of/c 'unix 'windows)) path-for-some-system?)]
 [get-pure-port                 (->* (url?) ((listof string?)) input-port?)]
 [get-impure-port               (->* (url?) ((listof string?)) input-port?)]
 [post-pure-port                (->* (url? (or/c #f bytes?)) ((listof string?)) input-port?)]
 [post-impure-port              (->* (url? bytes?) ((listof string?)) input-port?)]
 [head-pure-port                (->* (url?) ((listof string?)) input-port?)]
 [head-impure-port              (->* (url?) ((listof string?)) input-port?)]
 [delete-pure-port              (->* (url?) ((listof string?)) input-port?)]
 [delete-impure-port            (->* (url?) ((listof string?)) input-port?)]
 [put-pure-port                 (->* (url? (or/c #f bytes?)) ((listof string?)) input-port?)]
 [put-impure-port               (->* (url? bytes?) ((listof string?)) input-port?)]
 [display-pure-port             (-> input-port? void?)]
 [purify-port                   (-> input-port? string?)]
 [netscape/string->url          (-> string? url?)]
 [call/input-url                (case-> (-> url?
                                    (-> url? input-port?)
                                    (-> input-port? any) any)
                                (-> url?
                                    (-> url? (listof string?) input-port?)
                                    (-> input-port? any) (listof string?) any))]
 [combine-url/relative          (-> url? string? url?)]
 [url-exception?                (-> any/c boolean?)]
 [current-proxy-servers         (parameter/c (or/c #f (listof (list/c string? string? number?))))]
 [file-url-path-convention-type (parameter/c (or/c 'unix 'windows))])

