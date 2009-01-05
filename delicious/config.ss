(module config mzscheme
  
  (require (file "throttle.ss"))
  
  ;; username : (parameter string)
  (define current-username
    (make-parameter
     #f
     (lambda (val)
       (if (string? val)
           val
           (raise (make-exn:fail:contract
                   (format "Expected string, received ~a." val)
                   (current-continuation-marks)))))))
  
  ;; password : (parameter string)
  (define current-password
    (make-parameter
     #f
     (lambda (val)
       (if (string? val)
           val
           (raise (make-exn:fail:contract
                   (format "Expected string, received ~a." val)
                   (current-continuation-marks)))))))
  
  ;; base-url : (parameter string)
  ;;
  ;; Gets/sets the base URL for the del.icio.us API, WITHOUT a trailing slash.
  ;;
  ;; Because ssl-url.ss does not understand the "https://" protocol, 
  ;; the URL must be of the form "http://api.del.icio.us:443/blah".
  (define current-base-url
    (make-parameter
     "http://api.del.icio.us:443/v1"
     (lambda (val)
       (if (string? val)
           (if (eq? (string-ref val (sub1 (string-length val))) #\/)
               (raise (make-exn:fail:contract
                       (format "Base URL must not have a trailing slash: ~a." val)
                       (current-continuation-marks)))
               val)
           (raise (make-exn:fail:contract
                   (format "Expected string, received ~a." val)
                   (current-continuation-marks)))))))
  
  ;; current-throttle : (parameter throttle)
  ;;
  ;; The throttle control to use to prevent requests being made too quickly.
  (define current-throttle
    (make-parameter
     (make-throttle 1000)
     (lambda (val)
       (if (and (throttle? val) (>= (throttle-delay val) 1000))
           val
           (raise (make-exn:fail:contract
                   (format "Expected throttle with a delay >= 1000ms, received ~a" val)
                   (current-continuation-marks)))))))
  
  ;; dump-request-urls? : (parameter boolean)
  (define dump-request-urls?
    (make-parameter #f))
  
  ;; dump-raw-responses? : (parameter boolean)
  ;(define dump-raw-responses?
  ;  (make-parameter #f))
  
  ;; dump-sxml-responses? : (parameter boolean)
  (define dump-sxml-responses?
    (make-parameter #f))

  ; Provide statements --------------------------- 
  
  (provide current-username
           current-password
           current-base-url
           current-throttle
           dump-request-urls?
           ;dump-raw-responses?
           dump-sxml-responses?)
  
  )