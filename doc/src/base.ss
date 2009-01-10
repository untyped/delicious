(module base mzscheme

  (require (lib "etc.ss")
           (lib "eval.ss" "scribble")
           (lib "manual.ss" "scribble")
           (lib "scheme.ss" "scribble")
           (lib "struct.ss" "scribble")
           (lib "urls.ss" "scribble"))
  
  (provide (all-from (lib "eval.ss" "scribble"))
           (all-from (lib "manual.ss" "scribble"))
           (all-from (lib "urls.ss" "scribble"))
           lib-name
           lib-version
           api-name
           schemerepl)

  (define lib-name "Delicious client")
  (define lib-version "v1.0")
  
  (define api-name "del.icio.us")
  
  (define-syntax (schemerepl stx)
    (syntax-case stx ()
      ; (_ input result input result input result ...)
      [(_ term ...)
       (let ([terms (syntax->list #'(term ...))])
         #`(make-table
            #f
            (list #,@(if (= (remainder (length terms) 2) 0)
                         (let loop ([terms terms] [input? #t])
                           (if (null? terms)
                               null
                               (let ([head (car terms)]
                                     [tail (cdr terms)])
                                 (append (if input?
                                             (list #`(list (make-flow (list (make-paragraph (list (hspace 2)
                                                                                                  (tt "> ")
                                                                                                  (scheme #,head)))))))
                                             (if (eq? (syntax-object->datum head) 'void)
                                                 null
                                                 (list #`(list (make-flow (list (make-paragraph (list (hspace 2)
                                                                                                      (schemeresult #,head)))))))))
                                         (loop tail (not input?))))))
                         (error "schemerepl requires an even number of arguments.")))))]))
  
  )
