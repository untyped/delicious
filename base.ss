(module base mzscheme
  
  ; Structure types ------------------------------
  
  (define-struct (exn:delicious exn) ())
  (define-struct (exn:fail:delicious exn:fail) ())
  
  ;; exn:delicious:auth : exn
  ;;
  ;; Raised if bad credentials were supplied (HTTP code 401).
  (define-struct (exn:delicious:auth exn:delicious) ())
  
  ;; exn:fail:delicious:throttled : exn:fail
  ;;
  ;; Raised if delicious throttled a request (HTTP code 503).
  (define-struct (exn:fail:delicious:throttled exn:fail:delicious) ())
  
  ;; exn:fail:delicious:parse : exn:fail
  ;;
  ;; Raised if we had a problem parsing the XML response data.
  (define-struct (exn:fail:delicious:parse exn:fail:delicious) (fragment))
  
  ; Variables ------------------------------------
    
  ;; long-date-format : string
  ;;
  ;; The format in which del.icio.us sends/receives full timestamps
  ;; (in the format accepted by SRFI 19's string->date and date->string).
  (define long-date-format "~Y-~m-~dT~H:~M:~SZ")
  
  ;; short-date-format : string
  ;;
  ;; The format in which del.icio.us sends/receives day-only dates
  ;; (in the format accepted by SRFI 19's string->date and date->string).
  (define short-date-format "~Y-~m-~d")
  
  ; Provide statements --------------------------- 
  
  (provide (all-defined))
  
  )