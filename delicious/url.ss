(module url mzscheme
  
  (require (lib "contract.ss")
           (lib "etc.ss")
           (lib "plt-match.ss")
           (lib "uri-codec.ss" "net")
           (all-except (lib "list.ss" "srfi" "1") any)
           (lib "string.ss" "srfi" "13")
           (lib "time.ss" "srfi" "19")
           (file "base.ss")
           (file "config.ss"))
  
  ; Arguments ------------------------------------
  
  ;; empty : symbol
  ;;
  ;; A unique value used to represent unspecified arguments.
  (define empty (gensym 'empty))
  
  ;; empty? : any -> boolean
  ;;
  ;; Returns #t if the argument is the empty value.
  (define (empty? x)
    (eq? x empty))
  
  ; URLs -----------------------------------------
  
  ;; format-url : string [(U (alist-of symbol (U string symbol number boolean empty)) #f)] -> string
  (define format-url
    (let* ([format-argument-value
            (match-lambda
              [(? empty? val)                 null]
              [(? string? val)                (uri-encode val)]
              [(? symbol? val)                (uri-encode (symbol->string val))]
              [(? number? val)                (uri-encode (number->string val))]
              [(? srfi:date? val)             (date->string val long-date-format)]
              [(and vals `(,(? string?) ...)) (uri-encode (string-join vals " "))]
              [#t                             "yes"]
              [#f                             "no"])]
           [format-argument
            (match-lambda
              [(list-rest key (? empty? val)) null]
              [(list-rest key val)
               (list (string-append (symbol->string key) "=" (format-argument-value val)))])])
      (opt-lambda (path [arguments #f])
        (if arguments
            (string-append (current-base-url) path "?" (string-join (append-map format-argument arguments) "&"))
            (string-append (current-base-url) path)))))
  
  ;; last-updated-url : -> string
  (define (last-updated-url)
    (format-url "/posts/update"))
  
  ;; get-tags-url : -> string
  (define (get-tags-url)
    (format-url "/tags/get"))
  
  ;; rename-tag-url : string string -> string
  (define (rename-tag-url old new)
    (format-url "/tags/rename" `((old . ,old)
                                 (new . ,new))))
  
  ;; get-posts-url : [(U string empty)]
  ;;                 [(U date empty)]
  ;;                 [(U string empty)]
  ;;              -> string
  (define get-posts-url
    (opt-lambda ([tag empty] [date empty] [url empty])
      (format-url "/posts/get" `((tag . ,tag)
                                 (dt  . ,date)
                                 (url . ,url)))))
  
  ;; recent-posts-url : [(U string empty)] [(U number empty)] -> string
  (define recent-posts-url
    (opt-lambda ([tag empty] [count empty])
      (format-url "/posts/recent" `((tag   . ,tag)
                                    (count . ,count)))))
  
  ;; all-posts-url : [(U string empty)] -> string
  (define all-posts-url
    (opt-lambda ([tag empty])
      (format-url "/posts/all" `((tag . ,tag)))))
  
  ;; post-dates-url : [(U string empty)] -> string
  (define post-dates-url
    (opt-lambda ([tag empty])
      (format-url "/posts/dates" `((tag . ,tag)))))
  
  ;; add-post-url : string
  ;;                string
  ;;                [(U string empty)]
  ;;                [(U (list-of string) empty)]
  ;;                [(U date empty)]
  ;;                [(U boolean empty)]
  ;;                [(U boolean empty)]
  ;;             -> string
  (define add-post-url
    (opt-lambda (url description [extended empty] [tags empty] [date empty] [replace? empty] [shared? empty])
      (format-url "/posts/add" `((url         . ,url)
                                 (description . ,description)
                                 (extended    . ,extended)
                                 (tags        . ,tags)
                                 (dt          . ,date)
                                 (replace     . ,replace?)
                                 (shared      . ,shared?)))))
  
  ;; delete-post-url : string -> string
  (define (delete-post-url url)
    (format-url "/posts/delete" `((url . ,url))))
  
  ;; all-bundles-url : -> string
  (define (all-bundles-url)
    (format-url "/tags/bundles/all"))
  
  ;; set-bundle-url : string (list-of string) -> string
  (define (set-bundle-url bundle tags)
    (format-url "/tags/bundles/set" `((bundle . ,bundle)
                                      (tags   . ,tags))))
  
  ;; delete-bundle-url : string  -> string
  (define (delete-bundle-url bundle)
    (format-url "/tags/bundles/set" `((bundle . ,bundle))))
  
  ; Provide statements ---------------------------
  
  ;; maybe/c : contract -> contract
  ;;
  ;; Given a contract C, returns a contract that permits anything
  ;; that C permits, or the empty value.
  (define (maybe/c contract)
    (or/c contract empty?))
  
  (provide maybe/c
           empty
           empty?)
  
  (provide/contract
   [last-updated-url  (-> string?)]
   [get-tags-url      (-> string?)]
   [rename-tag-url    (-> string? string? string?)]
   [get-posts-url     (opt-> ()
                             ((maybe/c string?)
                              (maybe/c srfi:date?)
                              (maybe/c string?))
                             string?)]
   [recent-posts-url  (opt-> ()
                             ((maybe/c string?) (maybe/c integer?))
                             string?)]
   [all-posts-url     (opt-> () ((maybe/c string?)) string?)]
   [post-dates-url    (opt-> () ((maybe/c string?)) string?)]
   [add-post-url      (opt-> (string? string?)
                             ((maybe/c string?)
                              (maybe/c (listof string?))
                              (maybe/c srfi:date?)
                              (maybe/c boolean?)
                              (maybe/c boolean?))
                             string?)]
   [delete-post-url   (-> string? string?)]
   [all-bundles-url   (-> string?)]
   [set-bundle-url    (-> string? (listof string?) string?)]
   [delete-bundle-url (-> string? string?)])
  
  )