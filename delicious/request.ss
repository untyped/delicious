(module request mzscheme
  
  (require (lib "contract.ss")
           (lib "plt-match.ss")
           (lib "pretty.ss")
           (lib "base64.ss" "net")
           (lib "cut.ss" "srfi" "26"))
  
  (require (planet "ssax.ss" ("lizorkin" "ssax.plt" 1)))
  
  (require (file "base.ss")
           (file "config.ss")
           (file "ssl-url.ss")
           (file "throttle.ss"))
  
  ; Variables ------------------------------------
  
  ;; http-code-regexp : regexp
  ;;
  ;; Extracts the response code from an HTTP status line.
  ;;
  ;; This is supposed to be a little slack - we only care about the code.
  (define http-code-regexp 
    #rx"^HTTP/[0-9.]+[ ]+([0-9][0-9][0-9])")
  
  ; Procedures -----------------------------------
  
  ;; http-authorization-header : string string -> string
  (define (http-authorization-header username password)
    (let ([username-bytes (string->bytes/utf-8 username)]
          [password-bytes (string->bytes/utf-8 password)])
      (string-append 
       "Authorization: Basic " 
       (bytes->string/utf-8 (base64-encode (bytes-append username-bytes #":" password-bytes))))))
  
  ;; send-request : string -> sexp | exn:delicious:auth
  (define (send-request url)
    (when (dump-request-urls?)
      (display url) 
      (newline))
    (let* ([url         (string->url url)]
           [req-headers (list (http-authorization-header (current-username) (current-password)))]
           [in          (call-with-throttle (current-throttle) 
                          (lambda () 
                            (printf "~n-----~nSending ~s ~s~n-----~n" url req-headers)
                            (get-impure-port url req-headers)))]
           [res-headers (purify-port in)])
      (match (regexp-match http-code-regexp res-headers)
        [(list _ "200")
         (let ([sxml (ssax:xml->sxml in null)])
           (close-input-port in)
           (when (dump-sxml-responses?)
             (pretty-print sxml))
           ; Strip off the <?xml ... ?> header:
           (caddr sxml))]
        [(list _ "401")
         (close-input-port in)
         (raise-exn exn:delicious:auth
           "Bad username/password.")]
        [(list _ "503")
         (close-input-port in)
         (raise-exn exn:fail:delicious:throttled
           "Throttled: please wait a bit before trying again.")]
        [(list _ code)
         (close-input-port in)
         (raise-exn exn:fail:delicious 
           (format "Could not handle response (HTTP code ~a)." code))]
        [other (raise-exn exn:fail:delicious
                 (format "Status line not found in delicious response headers:~n~a" res-headers))])))
  
  ; Provide statements --------------------------- 
  
  (provide/contract
   [send-request (-> string? (or/c null? pair?))])
  
  )