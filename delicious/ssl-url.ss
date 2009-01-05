(module ssl-url mzscheme
  
  (require (lib "unit.ss")
           (lib "contract.ss")
           (lib "url-structs.ss"  "net")
           (lib "url-sig.ss"      "net")
           (lib "url-unit.ss"     "net")
           (lib "tcp-sig.ss"      "net")
           (lib "ssl-tcp-unit.ss" "net"))

  ; Units ----------------------------------------
  
  (define-compound-unit url+tcp@
    (import)
    (export URL)
    (link [((TCP : tcp^)) (make-ssl-tcp@ #f #f #f #f #f #f #f)]
          [((URL : url^)) url@ TCP]))

  ; Procedures -----------------------------------
  
  (define-values/invoke-unit/infer 
    url+tcp@)

  ; Provide statements --------------------------- 
  
  (provide (struct url (scheme
                        user
                        host
                        port
                        path-absolute?
                        path
                        query
                        fragment))
           (struct path/param (path param)))
  
  (provide/contract
   [string->url           (-> (or/c bytes? string?) url?)]
   [url->string           (-> url? string?)]

   [get-pure-port         (opt-> (url?) ((listof string?)) input-port?)]
   [get-impure-port       (opt-> (url?) ((listof string?)) input-port?)]
   [post-pure-port        (opt-> (url? (or/c false/c bytes?)) ((listof string?)) input-port?)]
   [post-impure-port      (opt-> (url? bytes?) ((listof string?)) input-port?)]
   [head-pure-port        (opt-> (url?) ((listof string?)) input-port?)]
   [head-impure-port      (opt-> (url?) ((listof string?)) input-port?)]
   [delete-pure-port      (opt-> (url?) ((listof string?)) input-port?)]
   [delete-impure-port    (opt-> (url?) ((listof string?)) input-port?)]
   [put-pure-port         (opt-> (url? (or/c false/c bytes?)) ((listof string?)) input-port?)]
   [put-impure-port       (opt-> (url? bytes?) ((listof string?)) input-port?)]
   [display-pure-port     (-> input-port? void?)]
   [purify-port           (-> input-port? string?)]
   [netscape/string->url  (-> string? url?)]
   [call/input-url        (opt->* (url?
                                   (opt-> (url?) ((listof string?)) input-port?)
                                   (-> input-port? any))
                                  ((listof string?))
                                  any)]
   [combine-url/relative  (-> url? string? url?)]
   [url-exception?        (-> any/c boolean?)]
   [current-proxy-servers (case-> (-> (or/c false/c (listof (list/c string? string? number?))) void?)
                                  (-> (or/c false/c (listof (list/c string? string? number?)))))])
  
  )

