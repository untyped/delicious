(module api mzscheme
  
  (require (lib "contract.ss")
           (lib "etc.ss")
           (lib "plt-match.ss")
           (lib "pretty.ss")
           (all-except (lib "list.ss" "srfi" "1") any)
           (lib "time.ss" "srfi" "19"))
  
  (require (file "base.ss")
           (file "config.ss")
           (file "request.ss")
           (file "result-parse.ss")
           (file "result-struct.ss")
           (file "url.ss"))
  
  ; API wrapper procedures -----------------------
  
  ;; last-updated : -> date
  (define (last-updated)
    (parse-update-element
     (send-request (last-updated-url))))
  
  ;; get-tags : -> (alist-of string integer)
  (define (get-tags)
    (parse-tags-element
     (send-request (get-tags-url))))
  
  ;; rename-tag! : string string -> void
  (define (rename-tag! old new)
    (parse-result-element
     (send-request (rename-tag-url old new))))
  
  ;; get-posts : [(U string empty)]
  ;;             [(U date empty)]
  ;;             [(U string empty)]
  ;;          -> (list-of post)
  (define get-posts
    (opt-lambda ([tag empty] [date empty] [url empty])
      (parse-posts-element
       (send-request (get-posts-url tag date url)))))
  
  ;; recent-posts : [(U string empty)] [(U number empty)] -> (list-of post)
  (define recent-posts
    (opt-lambda ([tag empty] [count empty])
      (parse-posts-element
       (send-request (recent-posts-url tag count)))))
  
  ;; all-posts : [(U string empty)] -> (list-of post)
  (define all-posts
    (opt-lambda ([tag empty])
      (parse-posts-element
       (send-request (all-posts-url tag)))))
  
  ;; post-dates : [(U string empty)] -> (alist-of date integer)
  (define post-dates
    (opt-lambda ([tag empty])
      (parse-dates-element
       (send-request (post-dates-url tag)))))
  
  ;; add-post! : post
  ;;             [(U boolean empty)]
  ;;             [(U boolean empty)]
  ;;         -> void
  (define add-post!
    (opt-lambda (p [replace? empty] [shared? empty])
      (match p
        [(struct post (url description extended tags date))
         (add-post/raw! url
                        description
                        (if extended extended empty)
                        (if (null? tags) empty tags)
                        (if date date empty)
                        replace?
                        shared?)])))
  
  ;; add-post/raw! : string
  ;;                 string
  ;;                 [(U string empty)]
  ;;                 [(U (list-of string) empty)]
  ;;                 [(U date empty)]
  ;;                 [(U boolean empty)]
  ;;                 [(U boolean empty)]
  ;;             -> void
  (define add-post/raw!
    (opt-lambda (url description [extended empty] [tags empty] [date empty] [replace? empty] [shared? empty])
      (parse-result-element
       (send-request (add-post-url url description extended tags date replace? shared?)))))
  
  ;; delete-post! : post -> void
  (define (delete-post! post)
    (delete-post/raw! (post-url post)))
  
  ;; delete-post/raw! : string -> void
  (define (delete-post/raw! url)
    (parse-result-element
     (send-request (delete-post-url url))))
  
  ;; all-bundles : -> (list-of bundle)
  (define (all-bundles)
    (parse-bundles-element
     (send-request (all-bundles-url))))
  
  ;; update-bundle! : bundle -> void
  (define (update-bundle! bundle)
    (update-bundle/raw! (bundle-name bundle)
                        (bundle-tags bundle)))
  
  ;; update-bundle/raw! : string (list-of string) -> void
  (define (update-bundle/raw! name tags)
    (parse-result-element
     (send-request (set-bundle-url name tags))))
  
  ;; delete-bundle! : bundle -> void
  (define (delete-bundle! bundle)
    (delete-bundle/raw! (bundle-name bundle)))
  
  ;; delete-bundle/raw! : string -> void
  (define (delete-bundle/raw! name)
    (parse-result-element
     (send-request (delete-bundle-url name))))
  
  ; Provide statements --------------------------- 
  
  (provide/contract
   [last-updated       (-> srfi:date?)]
   [get-tags           (-> (listof (cons/c string? integer?)))]
   [rename-tag!        (-> string? string? void?)]
   [get-posts          (opt-> ()
                              ((maybe/c string?)
                               (maybe/c srfi:date?)
                               (maybe/c string?))
                              (listof post?))]
   [recent-posts       (opt-> ()
                              ((maybe/c string?) (maybe/c (and/c integer? (between/c 0 100))))
                              (listof post?))]
   [all-posts          (opt-> () ((maybe/c string?)) (listof post?))]
   [post-dates         (opt-> () ((maybe/c string?)) (listof (cons/c srfi:date? integer?)))]
   [add-post!          (opt-> (post?)
                              ((maybe/c boolean?)
                               (maybe/c boolean?))
                              void?)]
   [add-post/raw!      (opt-> (string? string?)
                              ((maybe/c string?)
                               (maybe/c (listof string?))
                               (maybe/c srfi:date?)
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
  
  )