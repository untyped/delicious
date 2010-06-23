#lang scheme

(require "base.ss")

(require net/base64
         (ssax-in ssax)
         "config.ss"
         "ssl-url.ss"
         "throttle.ss")

; Variables ------------------------------------

; Extracts the response code from an HTTP status line.
;
; This is supposed to be a little slack - we only care about the code.
;
; regexp
(define http-code-regexp 
  #rx"^HTTP/[0-9.]+[ ]+([0-9][0-9][0-9])")

; Procedures -----------------------------------

; string string -> string
(define (http-authorization-header username password)
  (let ([username-bytes (string->bytes/utf-8 username)]
        [password-bytes (string->bytes/utf-8 password)])
    (string-append 
     "Authorization: Basic " 
     (bytes->string/utf-8 (base64-encode (bytes-append username-bytes #":" password-bytes))))))

; string -> sexp | exn:delicious:auth
(define (send-request url)
  (when (dump-request-urls?)
    (display url) 
    (newline))
  (let* ([url         (string->url url)]
         [req-headers (list (http-authorization-header (current-username) (current-password)))]
         [in          (call-with-throttle (current-throttle) 
                                          (lambda () 
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

; Provides ---------------------------------------

(provide/contract
 [send-request (-> string? (or/c null? pair?))])
