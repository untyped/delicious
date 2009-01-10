(module result-parse mzscheme
  
  (require (lib "contract.ss")
           (lib "plt-match.ss")
           (lib "string.ss")
           (lib "time.ss" "srfi" "19")
           (planet "xml.ss" ("jim" "webit.plt" 1 5))
           (file "base.ss")
           (file "result-struct.ss"))
  
  ; Parsing XML elements -------------------------
  
  ;; raise-parse-exn : -> void | exn:fail:delicious:parse
  (define (raise-parse-exn fragment)
    (raise (make-exn:fail:delicious:parse
            "Failed to parse XML fragment."
            (current-continuation-marks)
            fragment)))
  
  ;; parse-result-element : sxml -> void | exn:fail:delicious
  (define (parse-result-element elem)
    (xml-match elem
      [(result code: ,message)
       (if (equal? message "done")
           (void)
           (raise (make-exn:fail:delicious
                   (format "del.icio.us returned an error: ~a" message)
                   (current-continuation-marks))))]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-update-element : sxml -> date
  (define (parse-update-element elem)
    (xml-match elem
      [(update time: ,time)
       (parse-long-date time)]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-tags-element : sxml -> (alist-of string integer)
  (define (parse-tags-element elem)
    (xml-match elem
      [(tags ,tags ...)
       (map parse-tag-element tags)]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-tag-element : sxml -> (cons string integer)
  (define (parse-tag-element elem)
    (xml-match elem
      [(tag tag:   ,tag
            count: ,count)
       (cons tag (parse-number count))]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-posts-element : sxml -> (list-of post)
  (define (parse-posts-element elem)
    (xml-match elem
      [(posts user:   [,user   #f]
              tag:    [,tag    #f]
              dt:     [,date   #f]
              update: [,update #f]
              ,posts ...)
       (map parse-post-element posts)]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-post-element : sxml -> post
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
       (make-post url 
                  description
                  extended
                  (parse-list-of-strings tag)
                  (parse-long-date date))]
      [,any (error "Post not matched" elem)]))

  ;; parse-dates-element : sxml -> (alist-of date integer)
  (define (parse-dates-element elem)
    (xml-match elem
      [(dates user: [,user   #f]
              tag:  [,tag    #f]
              ,dates ...)
       (map parse-date-element dates)]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-date-element : sxml -> (cons date integer)
  (define (parse-date-element elem)
    (xml-match elem
      [(date date:  ,date
             count: ,count)
       (cons (parse-short-date date)
             (parse-number count))]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-bundles-element : sxml -> (list-of bundle)
  (define (parse-bundles-element elem)
    (xml-match elem
      [(bundles ,bundles ...)
       (map parse-bundle-element bundles)]
      [,any (raise-parse-exn elem)]))
  
  ;; parse-bundle-element : sxml -> bundle
  (define (parse-bundle-element elem)
    (xml-match elem
      [(bundle name: ,name
               tags: ,tags)
       (list name (parse-list-of-strings tags))]
      [,any (raise-parse-exn elem)]))
  
  ; Parsing atomic values ------------------------
  
  ;; parse-long-date : string -> date
  (define (parse-long-date str)
    (string->date str long-date-format))
  
  ;; parse-short-date : string -> date
  (define (parse-short-date str)
    (string->date str short-date-format))
  
  ;; parse-number : string -> number
  (define parse-number string->number)
  
  ;; parse-list-of-strings : string -> (list-of string)
  (define (parse-list-of-strings str)
    (regexp-split #rx" " str))
  
  ;; parse-boolean : string -> boolean
  (define (parse-boolean str)
    (if (equal? str "yes")
        #t
        #f))
  
  ; Provide statements --------------------------- 
  
  ;; sxml/c : contract
  ;;
  ;; This is a really lax contract. We just want it to be fast.
  (define sxml/c pair?)
  
  (provide/contract
   [parse-result-element  (-> sxml/c void?)]
   [parse-update-element  (-> sxml/c srfi:date?)]
   [parse-tags-element    (-> sxml/c (listof (cons/c string? integer?)))]
   [parse-posts-element   (-> sxml/c (listof post?))]
   [parse-dates-element   (-> sxml/c (listof (cons/c srfi:date? integer?)))]
   [parse-bundles-element (-> sxml/c (listof bundle?))])
  
  )
